// The Swift Programming Language
// https://docs.swift.org/swift-book

import NSUI
import Rearrange
import SwiftTreeSitter
import TreeSitterHTML
import TreeSitterMarkdown
import TreeSitterMarkdownInline
import TreeSitterSwift

// Keeps a copy of the tree around in case we want to play with it
class HighlighterParser {
	let name: String
	let languageProvider: LanguageProvider
	let queries: [Query.Definition: Query]
	var text: String = ""
	let configuration: LanguageConfiguration
	let maxNestedDepth = 5

	init(configuration: LanguageConfiguration, languageProvider: LanguageProvider) {
		self.name = configuration.name
		self.queries = configuration.queries
		self.languageProvider = languageProvider
		self.configuration = configuration
	}

	func load(text: String) {
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

		return captures(parser: parser, in: tree, depth: 0)
	}

	func captures(parser: Parser, in tree: Tree, depth: Int) -> [QueryCapture] {
		if depth >= maxNestedDepth {
			return []
		}

		var result: [QueryCapture] = []

		let injectionsCursor = queries[.injections]!.execute(in: tree, depth: 4).resolve(with: .init(string: text)).injections()
		var rangesByName: [String: [TSRange]] = [:]
		for injection in injectionsCursor {
			rangesByName[injection.name, default: []].append(injection.tsRange)
		}

		for (name, ranges) in rangesByName {
			guard let language = languageProvider.find(name: name) else {
				print("No language found for \(name)")
				continue
			}

			parser.includedRanges = ranges
			try! parser.setLanguage(language)
			let injectedTree = parser.parse(text)!.copy()!

			let highlights = queries[.highlights]!.execute(in: injectedTree).resolve(with: .init(string: text)).highlights()
			for h in highlights {
				print("\(name) injection highlights: \(h.nameComponents)")
				
			}

			result.append(contentsOf: captures(parser: parser, in: injectedTree, depth: depth + 1))
		}

		let highlightsCursor = queries[.highlights]!.execute(in: tree, depth: 4)
		while let match = highlightsCursor.next() {
			for capture in match.captures {
				result.append(capture)
			}
		}

		return result
	}
}

class LanguageProvider {
	var primary: String
	var parsersByName: [String: HighlighterParser]!

	init(primary: String) {
		self.primary = primary
	}

	var primaryLanguage: LanguageConfiguration {
		languagesByName[primary]!
	}

	var languages: [LanguageConfiguration] {
		languagesByName.values.map { $0 }
	}

	func find(name: String) -> Language? {
		languagesByName[name]?.language
	}

	let languagesByName: [String: LanguageConfiguration] = [
		// TODO: Make this configurable
		"markdown": try! LanguageConfiguration(
			.init(tree_sitter_markdown()), name: "markdown", queriesURL: Bundle.module.bundleURL.appending(path: "Contents/Resources/Markdown")
		),
		"markdown_inline": try! LanguageConfiguration(
			.init(tree_sitter_markdown_inline()), name: "markdown_inline", queriesURL: Bundle.module.bundleURL.appending(path: "Contents/Resources/MarkdownInline")
		),
		"html": try! LanguageConfiguration(
			.init(tree_sitter_html()), name: "html", queriesURL: Bundle.module.bundleURL.appending(path: "Contents/Resources/HTML")
		),
		"swift": try! LanguageConfiguration(
			.init(tree_sitter_swift()), name: "swift", queriesURL: Bundle.module.bundleURL.appending(path: "Contents/Resources/Swift")
		)
	]
}

class Highlighter: NSObject, NSTextStorageDelegate {
	let textStorage: NSTextStorage
	let theme: Theme
	let styles: HighlighterStyleContainer
	let parser: HighlighterParser
	let languageProvider = LanguageProvider(primary: "markdown")

	init(textStorage: NSTextStorage, theme: Theme, styles: HighlighterStyleContainer) {
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
			if let style = styles.style(for: name) {
				result.append(
					Highlight(
						name: name,
						range: capture.range,
						style: style.attributes(
							for: capture.range,
							theme: theme,
							in: textStorage
						)
					)
				)
			} else {
				unknownStyles.insert(name)
			}
		}
		
#if DEBUG
		print("Unknown types: \(unknownStyles)")
#endif
		
		return result.filter { range.contains($0.range.lowerBound) && range.contains($0.range.upperBound) }
	}

	func highlights(at position: Int) -> [Highlight] {
		highlights(for: .init(textStorage: textStorage)).filter { $0.range.contains(position) }
	}

	func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {}

	func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
		parser.load(text: textStorage.string)

		for highlight in highlights(for: NSRange(textStorage: textStorage)) {
			textStorage.addAttributes(highlight.style, range: highlight.range)
		}
	}
}
