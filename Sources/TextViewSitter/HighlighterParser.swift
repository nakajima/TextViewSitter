//
//  HighlighterParser.swift
//
//
//  Created by Pat Nakajima on 5/26/24.
//

import Foundation
import Rearrange
import SwiftTreeSitter

enum Benchy {
	static func measure<T>(_ label: String, block: @escaping () throws -> T) rethrows -> T? {
		let clock = ContinuousClock()
		var value: T?
		let result = try clock.measure { value = try block() }
		print("\(label) took \(result)")
		return value
	}

	static func measure<T>(_ label: String, block: @escaping () async throws -> T) async rethrows -> T? {
		let clock = ContinuousClock()
		var value: T?
		let result = try await clock.measure { value = try await block() }
		print("\(label) took \(result)")
		return value
	}
}

// Keeps a copy of the tree around in case we want to play with it
class HighlighterParser {
	let name: String
	let languageProvider: LanguageProvider
	var text: String = ""
	let configuration: LanguageConfiguration
	let maxNestedDepth = 5

	public struct Capture {
		public let language: String
		public let range: NSRange
		public let nodeType: String?
		public let index: Int
		public let nameComponents: [String]
		public let patternIndex: Int
		public let metadata: [String: String]

		public var name: String {
			nameComponents.joined(separator: ".")
		}
	}

	init(configuration: LanguageConfiguration, languageProvider: LanguageProvider) {
		self.name = configuration.name
		self.languageProvider = languageProvider
		self.configuration = configuration
	}

	func load(text: String) {
		self.text = text
	}

	func captures() async throws -> [Capture] {
		if text.isEmpty {
			return []
		}

		try Task.checkCancellation()

		let parser = Parser()
		try! parser.setLanguage(languageProvider.primaryLanguage.language)

		guard let tree = parser.parse(text)?.copy() else {
			assertionFailure("No tree for parser: \(self)")
			return []
		}

		return try await Benchy.measure("finding captures") {
			try await self.captures(
				parser: parser,
				language: self.languageProvider.primaryLanguage,
				in: tree,
				depth: 0
			)
		}!
	}

	func captures(
		parser _: Parser,
		language config: LanguageConfiguration,
		in tree: Tree,
		depth: Int
	) async throws -> [Capture] {
		try Task.checkCancellation()

		var result: [Capture] = []

		let highlightsCursor = config.queries[.highlights]!.execute(in: tree, depth: 1)
		while let match = highlightsCursor.next() {
			for queryCapture in match.captures {
				let capture = Capture(
					language: config.name,
					range: queryCapture.range,
					nodeType: queryCapture.node.nodeType,
					index: queryCapture.index,
					nameComponents: queryCapture.nameComponents,
					patternIndex: queryCapture.patternIndex,
					metadata: queryCapture.metadata
				)

				result.append(capture)
			}
		}

		if let injectionsCursor = config.queries[.injections]?.execute(in: tree, depth: 1) {
			let captures = try await withThrowingTaskGroup(of: [Capture].self) { group in
				while let next = injectionsCursor.next() {
					if let injection = next.injection(with: self.text.predicateTextProvider),
					   let config = self.languageProvider.find(name: injection.name)
					{
						group.addTask {
							let parser = Parser()

							try! parser.setLanguage(config.language)
							parser.includedRanges = [injection.tsRange]

							// TODO: Trying to pass the existing tree in here causes crashes on larger documents...
							let injectedTree = parser.parse(self.text)!.copy()!
							return try await self.captures(
								parser: parser,
								language: config,
								in: injectedTree,
								depth: depth + 1
							)
						}
					}
				}

				var localResults: [Capture] = []
				for try await result in group {
					localResults.append(contentsOf: result)
				}
				return localResults
			}

			result.append(contentsOf: captures)
		}

		return result
	}
}
