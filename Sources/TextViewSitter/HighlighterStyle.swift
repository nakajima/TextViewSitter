//
//  HighlighterStyle.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI
import Rearrange
import SwiftUI

public protocol HighlighterStyle {
	var name: String { get }
	func attributes(for range: NSRange, theme: Theme, in storage: NSTextStorage) -> [NSAttributedString.Key: Any]
}

struct LinkStyle: HighlighterStyle {
	let name = "text.reference"

	func attributes(for _: NSRange, theme: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[.foregroundColor: theme.colors.linkColor]
	}
}

struct CodeStyle: HighlighterStyle {
	let name = "text.code"

	func attributes(for _: NSRange, theme _: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[
			.foregroundColor: NSUIColor.cyan,
		]
	}
}

struct TextLiteralStyle: HighlighterStyle {
	let name = "text.literal"
	func attributes(for _: NSRange, theme _: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[
			.foregroundColor: NSUIColor.cyan,
		]
	}
}

struct BoldStyle: HighlighterStyle {
	let name = "text.strong"

	func attributes(for _: NSRange, theme: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[.font: theme.fonts.bold()]
	}
}

struct TitleStyle: HighlighterStyle {
	let name = "text.title"

	func attributes(for _: NSRange, theme: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[
			.font: theme.fonts.bold(),
		]
	}
}

struct StrongStyle: HighlighterStyle {
	let name = "text.strong"

	func attributes(for _: NSRange, theme: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[
			.font: theme.fonts.bold(),
		]
	}
}

struct EmphasisStyle: HighlighterStyle {
	let name = "text.emphasis"

	func attributes(for _: NSRange, theme: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[
			.font: theme.fonts.italics(),
		]
	}
}

struct PunctuationSpecialStyle: HighlighterStyle {
	let name = "punctuation.special"

	func attributes(for _: NSRange, theme _: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[
			.foregroundColor: NSUIColor.gray,
		]
	}
}

struct PunctuationDelimiterStyle: HighlighterStyle {
	let name = "punctuation.delimiter"

	public let priority = 2
	func attributes(for _: NSRange, theme _: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[
			.foregroundColor: NSUIColor.gray,
		]
	}
}

struct CodeBlockStyle: HighlighterStyle {
	let name = "text.code"

	func attributes(for _: NSRange, theme: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[
			.foregroundColor: theme.colors.textColor,
		]
	}
}

struct MethodStyle: HighlighterStyle {
	let name = "method"

	func attributes(for _: NSRange, theme _: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[
			.foregroundColor: NSUIColor.cyan,
		]
	}
}

struct KeywordStyle: HighlighterStyle {
	let name = "keyword"

	func attributes(for _: NSRange, theme _: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[
			.foregroundColor: NSUIColor(Color.pink),
		]
	}
}

public struct ListItemStyle: HighlighterStyle {
	public let name = "list-item"

	public func attributes(for range: NSRange, theme: Theme, in storage: NSTextStorage) -> [NSAttributedString.Key: Any] {
		let paragraphStyle = NSMutableParagraphStyle()

		if let line = storage.string[range] {
			var indentationLevel: CGFloat = 0
			var seenSpace = false
			for character in line {
				if seenSpace, !character.isWhitespace {
					break
				}

				indentationLevel += 1

				if character.isWhitespace {
					seenSpace = true
				}
			}

			paragraphStyle.firstLineHeadIndent = 0 // Indent for the first line
			paragraphStyle.headIndent = theme.letterWidth * indentationLevel // Indent for the wrapped lines
			paragraphStyle.lineSpacing = theme.lineSpacing
		}

		return [
			.paragraphStyle: paragraphStyle,
		]
	}
}

struct TagStyle: HighlighterStyle {
	let name = "tag"

	func attributes(for _: NSRange, theme _: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[
			.foregroundColor: NSUIColor.red,
		]
	}
}
