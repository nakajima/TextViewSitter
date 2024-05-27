// The Swift Programming Language
// https://docs.swift.org/swift-book

import NSUI
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
			result += "\(space)- \(node.nodeType!) \(node.tsRange.debugDescription) (\(text[node.range])\n"

			node.enumerateChildren { child in
				append(child, indent: indent + 1)
			}
		}

		append(rootNode, indent: 1)

		return result
	}
}

class Highlighter: NSObject {
	var theme: Theme
	let parser: HighlighterParser
	let languageProvider = LanguageProvider(primary: "markdown")
	var knownHighlights: [Highlight] = []
	var highlightTask: Task<Void, any Error>?

	init(theme: Theme) {
		self.theme = theme
		self.parser = HighlighterParser(
			configuration: languageProvider.primaryLanguage,
			languageProvider: languageProvider
		)

		super.init()
	}

	func highlights(for textStorage: NSTextStorage, result: @MainActor @escaping ([Highlight]) -> Void) {
		let theme = theme
		let parser = parser
		let storage = textStorage

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
							in: storage
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
