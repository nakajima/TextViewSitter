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
	var color: NSUIColor? { get set }
	var traits: Set<FontTrait> { get set }

	func refinement(for range: NSRange, theme: Theme, in storage: NSTextStorage) -> [NSAttributedString.Key: Any]
}

extension Style {
	func attributes(for range: NSRange, theme: Theme, in storage: NSTextStorage) -> [NSAttributedString.Key: Any] {
		var attributes: [NSAttributedString.Key: Any] = [:]

		var font: NSUIFont?

		if traits.contains(.bold) {
			font = theme.fonts.bold()
		}

		if traits.contains(.italic) {
			font = (font ?? theme.fonts.regular()).italics(ofSize: theme.fontSize)
		}

		if let font {
			attributes[.font] = font
		}

		if let color {
			attributes[.foregroundColor] = color
		}

		return attributes.merging(refinement(for: range, theme: theme, in: storage), uniquingKeysWith: { _, key in key })
	}

	func refinement(for _: NSRange, theme _: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: Any] {
		[:]
	}
}

struct GenericStyle: Style {
	var color: NSUIColor? = nil
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

	subscript(_ name: String) -> NSUIColor? {
		get {
			styles[name, default: GenericStyle()].color
		}

		set {
			styles[name, default: GenericStyle()].color = newValue
		}
	}

	subscript(_ name: String) -> Color? {
		get {
			if let color = styles[name, default: GenericStyle()].color {
				return Color(nsuiColor: color)
			} else {
				return nil
			}
		}

		set {
			if let newValue {
				styles[name, default: GenericStyle()].color = NSUIColor(newValue)
			}
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
	public var color: NSUIColor? = nil
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
