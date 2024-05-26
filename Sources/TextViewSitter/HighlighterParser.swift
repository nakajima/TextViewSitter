//
//  HighlighterParser.swift
//
//
//  Created by Pat Nakajima on 5/26/24.
//

import Foundation
import Rearrange
import SwiftTreeSitter

// Keeps a copy of the tree around in case we want to play with it
class HighlighterParser {
	let name: String
	let languageProvider: LanguageProvider
	var text: String = ""
	let configuration: LanguageConfiguration
	let maxNestedDepth = 5

	init(configuration: LanguageConfiguration, languageProvider: LanguageProvider) {
		self.name = configuration.name
		self.languageProvider = languageProvider
		self.configuration = configuration
	}

	func load(text: String) {
		// Oh no
		self.text = text
	}

	func captures() -> [QueryCapture] {
		if text.isEmpty {
			return []
		}

		let parser = Parser()
		try! parser.setLanguage(languageProvider.primaryLanguage.language)

		guard let tree = parser.parse(text)?.copy() else {
			assertionFailure("No tree for parser: \(self)")
			return []
		}

		return captures(parser: parser, language: languageProvider.primaryLanguage, in: tree, depth: 0)
	}

	func captures(parser: Parser, language config: LanguageConfiguration, in tree: Tree, depth: Int) -> [QueryCapture] {
		if depth >= maxNestedDepth {
			return []
		}

		var result: [QueryCapture] = []

		let highlightsCursor = config.queries[.highlights]!.execute(in: tree, depth: 1)
		while let match = highlightsCursor.next() {
			for capture in match.captures {
				if capture.name == "markup.raw.block" {
					print(capture)
				}
				result.append(capture)
			}
		}

		if let injectionsCursor = config.queries[.injections]?.execute(in: tree, depth: 1) {
			while let next = injectionsCursor.next() {
				if let injection = next.injection(with: text.predicateTextProvider),
				   let config = languageProvider.find(name: injection.name)
				{
					try! parser.setLanguage(config.language)
					parser.includedRanges = [injection.tsRange]
					let injectedTree = parser.parse(text)!.copy()!
					result.append(contentsOf: captures(parser: parser, language: config, in: injectedTree, depth: 4))
				} else {
					print("no injection? \(next)")
				}
			}
		}

		return result
	}
}
