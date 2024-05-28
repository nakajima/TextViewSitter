// The Swift Programming Language
// https://docs.swift.org/swift-book

import NSUI
import os
import Rearrange
import SwiftTreeSitter

extension Tree {
	func debugDescription(text: String) -> String {
		guard let rootNode else {
			return "<Tree: no root node>"
		}

		var result = "- Tree includedRanges=\(includedRanges)\n"

		func append(_ node: Node, indent: Int) {
			let space = Array(repeating: "  ", count: indent).joined(separator: "")
			result += "\(space)- \(node.nodeType!) \(node.tsRange.debugDescription) (\(String(describing: text[node.range]))\n"

			node.enumerateChildren { child in
				append(child, indent: indent + 1)
			}
		}

		append(rootNode, indent: 1)

		return result
	}
}

final class Highlighter: NSObject, Sendable {
	let parser: HighlighterParser
	let languageProvider = LanguageProvider(primary: "markdown")

	let _theme = OSAllocatedUnfairLock(initialState: Theme.default)
	var theme: Theme {
		get {
			_theme.withLock { $0 }
		}
		set {
			_theme.withLock { $0 = newValue }
		}
	}

	let _knownHighlights = OSAllocatedUnfairLock<[Highlight]>(initialState: [])
	var knownHighlights: [Highlight] {
		get {
			_knownHighlights.withLock { $0 }
		}
		set {
			_knownHighlights.withLock { $0 = newValue }
		}
	}

	let _highlightTask = OSAllocatedUnfairLock<Task<Void, any Error>?>(initialState: nil)
	var highlightTask: Task<Void, any Error>? {
		get {
			_highlightTask.withLock { $0 }
		}

		set {
			_highlightTask.withLock { $0 = newValue }
		}
	}

	override init() {
		self.parser = HighlighterParser(
			configuration: languageProvider.primaryLanguage,
			languageProvider: languageProvider
		)

		super.init()
	}

	func highlight(_ textStorage: NSTextStorage) {
		highlights(for: textStorage) { _ in
			self.applyStyles(in: textStorage)
		}
	}

	func highlights(for textStorage: NSTextStorage, result: @MainActor @escaping ([Highlight]) -> Void) {
		let theme = theme
		let parser = parser
		parser.load(text: textStorage.string)

		highlightTask?.cancel()
		highlightTask = Task {
			var highlights: [Highlight] = []
			var unknownStyles: Set<String> = []

			let captures = try await parser.captures()
			for capture in captures {
				let name = capture.nameComponents.joined(separator: ".")
				let style = theme.styles[name]
				highlights.append(
					Highlight(
						name: name,
						language: capture.language,
						nodeType: capture.nodeType,
						nameComponents: capture.nameComponents,
						range: capture.range,
						style: style?.attributes(
							for: capture.range,
							theme: theme,
							in: textStorage
						) ?? [:]
					)
				)

				if style == nil {
					unknownStyles.insert(name)
				}
			}

			#if DEBUG
				if !unknownStyles.isEmpty {
					print("Unknown types: \(unknownStyles)")
				}
			#endif

			let immutableHighlights = highlights
			await MainActor.run { self.knownHighlights = immutableHighlights }
			await result(immutableHighlights)
		}
	}

	func highlights(at position: Int) -> [Highlight] {
		knownHighlights.filter { $0.range.contains(position) }
	}

	func update(theme: Theme, for textStorage: NSTextStorage) {
		self.theme = theme
		updateKnownHighlights(for: textStorage)
		applyStyles(in: textStorage)
	}

	func applyStyles(in textStorage: NSTextStorage) {
		let fullRange = NSRange(textStorage: textStorage)
		textStorage.setAttributes(theme.typingAttributes, range: fullRange)

		for highlight in knownHighlights.reversed() {
			textStorage.addAttributes(highlight.style, range: highlight.range)
		}
	}

	// Goes through known highlights and updates with new styles
	private func updateKnownHighlights(for textStorage: NSTextStorage) {
		knownHighlights = knownHighlights.map { highlight in
			highlight.updating(to: theme, in: textStorage)
		}
	}
}
