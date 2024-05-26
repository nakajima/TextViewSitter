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
	var text: String = ""
	let configuration: LanguageConfiguration
	let maxNestedDepth = 5

	init(configuration: LanguageConfiguration, languageProvider: LanguageProvider) {
		self.name = configuration.name
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

		return captures(parser: parser, language: languageProvider.primaryLanguage, in: tree, depth: 0)
	}

	func captures(parser: Parser, language config: LanguageConfiguration, in tree: Tree, depth: Int) -> [QueryCapture] {
		if depth >= maxNestedDepth {
			return []
		}

		var result: [QueryCapture] = []

		let highlightsCursor = config.queries[.highlights]!.execute(in: tree, depth: 4)
		while let match = highlightsCursor.next() {
			for capture in match.captures {
				result.append(capture)
			}
		}

		let injectionsCursor = config.queries[.injections]!.execute(in: tree, depth: 4).resolve(with: .init(string: text)).injections()
		var rangesByName: [String: [NamedRange]] = [:]
		for injection in injectionsCursor {
			rangesByName[injection.name, default: []].append(injection)
		}

		for (name, namedRanges) in rangesByName {
			guard let injectionConfig = languageProvider.find(name: name) else {
				print("No language found for \(name)")
				continue
			}

			//			parser.includedRanges = ranges
			try! parser.setLanguage(injectionConfig.language)
			parser.includedRanges = namedRanges.map(\.tsRange)
			let injectedTree = parser.parse(text)!.copy()!

			print("\(name) content: \(namedRanges.map { text[$0.range] })")

			let highlights = injectionConfig.queries[.highlights]!.execute(in: injectedTree).resolve(with: .init(string: text)).highlights()
			for h in highlights {
				//				print("\(name) injection: \(h.nameComponents) \(text[h.range])")
			}

			result.append(contentsOf: captures(parser: parser, language: injectionConfig, in: injectedTree, depth: depth + 1))
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

	func find(name: String) -> LanguageConfiguration? {
		languagesByName[name]
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
		),
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

		return result
	}

	func highlights(at position: Int) -> [Highlight] {
		highlights(for: .init(textStorage: textStorage)).filter { $0.range.contains(position) }
	}

	func textStorage(_: NSTextStorage, willProcessEditing _: NSTextStorageEditActions, range _: NSRange, changeInLength _: Int) {}

	func textStorage(_ textStorage: NSTextStorage, didProcessEditing _: NSTextStorageEditActions, range _: NSRange, changeInLength _: Int) {
		parser.load(text: textStorage.string)

		let highlights = highlights(for: NSRange(textStorage: textStorage))

		for highlight in highlights {
			textStorage.addAttributes(highlight.style, range: highlight.range)
		}
	}
}
