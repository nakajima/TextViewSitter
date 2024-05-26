//
//  StyleBuilder.swift
//
//
//  Created by Pat Nakajima on 5/25/24.
//

import Foundation
import NSUI
import SwiftUI

public enum FontTrait {
	case bold, italic
}

public protocol Style {
	var color: NSUIColor { get set }
	var traits: Set<FontTrait> { get set }

	func refinement(for range: NSRange, theme: Theme, in storage: NSTextStorage) -> [NSAttributedString.Key: Any]
}

extension Style {
	func attributes(for range: NSRange, theme: Theme, in storage: NSTextStorage) -> [NSAttributedString.Key: Any] {
		var font = theme.fonts.regular()

		if traits.contains(.bold) {
			font = theme.fonts.bold()
		}

		if traits.contains(.italic) {
			font = font.italics(ofSize: theme.fontSize)
		}

		var attributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: color,
			.font: font,
		]

		return attributes.merging(refinement(for: range, theme: theme, in: storage), uniquingKeysWith: { key, _ in key })
	}

	func refinement(for _: NSRange, theme _: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[:]
	}
}

struct GenericStyle: Style {
	var color = NSUIColor(Color.primary)
	var traits: Set<FontTrait> = []
}

struct StyleBuilder {
	var styles: [String: any Style] = [:]

	init(block: (inout StyleBuilder) -> Void) {
		block(&self)
	}

	subscript(_ name: String) -> (any Style)? {
		get {
			styles[name]
		}

		set {
			styles[name] = newValue
		}
	}

	subscript(_ name: String) -> NSUIColor {
		get {
			styles[name, default: GenericStyle()].color
		}

		set {
			styles[name, default: GenericStyle()].color = newValue
		}
	}

	subscript(_ name: String) -> Color {
		get {
			Color(nsuiColor: styles[name, default: GenericStyle()].color)
		}

		set {
			styles[name, default: GenericStyle()].color = NSUIColor(newValue)
		}
	}

	subscript(_ name: String) -> Set<FontTrait> {
		get {
			styles[name, default: GenericStyle()].traits
		}

		set {
			styles[name, default: GenericStyle()].traits = newValue
		}
	}
}

public struct ListItemStyle: Style {
	#if os(macOS)
		public var color: NSUIColor = .textColor
	#else
		public var color: NSUIColor = NSUIColor(Color.primary)
	#endif
	public var traits: Set<FontTrait> = []

	public init() {}

	public func refinement(for range: NSRange, theme: Theme, in storage: NSTextStorage) -> [NSAttributedString.Key: Any] {
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
