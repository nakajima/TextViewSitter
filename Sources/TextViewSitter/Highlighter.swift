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

class Highlighter: NSObject, NSTextStorageDelegate {
	let textStorage: NSTextStorage
	var theme: Theme
	let styles: [String: any Style]
	let parser: HighlighterParser
	let languageProvider = LanguageProvider(primary: "markdown")
	var knownHighlights: [Highlight] = []

	init(textStorage: NSTextStorage, theme: Theme, styles: [String: any Style]) {
		self.textStorage = textStorage
		self.theme = theme
		self.styles = styles
		self.parser = HighlighterParser(configuration: languageProvider.primaryLanguage, languageProvider: languageProvider)

		super.init()

		textStorage.delegate = self
	}

	func highlights(for range: NSRange) -> [Highlight] {
		var result: [Highlight] = []
		var unknownStyles: Set<String> = []

		let captures = parser.captures()
		for capture in captures {
			let name = capture.nameComponents.joined(separator: ".")
			let style = styles[name]
			result.append(
				Highlight(
					name: name,
					nodeType: capture.node.nodeType,
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

		return result
	}

	func highlights(at position: Int) -> [Highlight] {
		knownHighlights.filter { $0.range.contains(position) }
	}

	func textStorage(_: NSTextStorage, willProcessEditing _: NSTextStorage.EditActions, range _: NSRange, changeInLength _: Int) {}

	func textStorage(_: NSTextStorage, didProcessEditing actions: NSTextStorage.EditActions, range _: NSRange, changeInLength _: Int) {
		guard actions.contains(.editedCharacters) else {
			return
		}

		applyStyles()
	}

	func applyStyles() {
		parser.load(text: textStorage.string)

		// Remove existing highlights
		let fullRange = NSRange(textStorage: textStorage)
		textStorage.setAttributes(theme.typingAttributes, range: fullRange)

		let highlights = highlights(for: NSRange(textStorage: textStorage))

		for highlight in highlights {
			textStorage.addAttributes(highlight.style, range: highlight.range)
		}

		knownHighlights = highlights
	}
}
