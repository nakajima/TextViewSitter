import Foundation
import NSUI
import SwiftTreeSitter

import TreeSitterHTML
import TreeSitterMarkdown
import TreeSitterMarkdownInline
import TreeSitterSwift
import TreeSitterYAML

class LanguageProvider {
	#if os(macOS)
		static let queriesURL = Bundle.module.bundleURL.appending(path: "Contents/Resources")
	#else
		static let queriesURL = Bundle.module.bundleURL
	#endif

	var primary: String
	var parsersByName: [String: HighlighterParser]!

	init(primary: String) {
		self.primary = primary
	}

	var primaryLanguage: LanguageConfiguration {
		Self.languagesByName[primary]!
	}

	var languages: [LanguageConfiguration] {
		Self.languagesByName.values.map { $0 }
	}

	func find(name: String) -> LanguageConfiguration? {
		return Self.languagesByName[name]
	}

	static let languagesByName: [String: LanguageConfiguration] = [
		// TODO: Make this configurable
		"markdown": try! LanguageConfiguration(
			.init(tree_sitter_markdown()), name: "markdown", queriesURL: LanguageProvider.queriesURL.appending(path: "Markdown")
		),
		"markdown_inline": try! LanguageConfiguration(
			.init(tree_sitter_markdown_inline()), name: "markdown_inline", queriesURL: LanguageProvider.queriesURL.appending(path: "MarkdownInline")
		),
		"html": try! LanguageConfiguration(
			.init(tree_sitter_html()), name: "html", queriesURL: LanguageProvider.queriesURL.appending(path: "HTML")
		),
		"swift": try! LanguageConfiguration(
			.init(tree_sitter_swift()), name: "swift", queriesURL: LanguageProvider.queriesURL.appending(path: "Swift")
		),
		"yml": try! LanguageConfiguration(
			.init(tree_sitter_yaml()), name: "yml", queriesURL: LanguageProvider.queriesURL.appending(path: "YAML")
		),
	]
}
