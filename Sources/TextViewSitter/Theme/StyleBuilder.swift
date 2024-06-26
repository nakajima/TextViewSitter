//
//  StyleBuilder.swift
//
//
//  Created by Pat Nakajima on 5/25/24.
//

import Foundation
import NSUI
import SwiftUI

public enum FontTrait: String, Comparable, Sendable {
	public static func < (lhs: FontTrait, rhs: FontTrait) -> Bool {
		lhs.rawValue < rhs.rawValue
	}

	case bold, italic
}

public protocol Style: Sendable {
	var color: NSUIColor? { get set }
	var traits: Set<FontTrait> { get set }
	var attributes: [NSAttributedString.Key: any Sendable] { get set }

	func refinement(for range: NSRange, theme: Theme, in storage: NSTextStorage) -> [NSAttributedString.Key: any Sendable]
}

public extension Style {
	var attributes: [NSAttributedString.Key: any Sendable] { [:] }

	func attributes(for range: NSRange, theme: Theme, in storage: NSTextStorage) -> [NSAttributedString.Key: any Sendable] {
		var attributes = attributes

		var font: NSUIFont?

		if !traits.isEmpty {
			font = theme.fonts.font(traits: traits)
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

	func refinement(for _: NSRange, theme _: Theme, in _: NSTextStorage) -> [NSAttributedString.Key: any Sendable] {
		[:]
	}
}

public struct GenericStyle: Style {
	public var name: String
	public var color: NSUIColor? = nil
	public var traits: Set<FontTrait> = []
	public var attributes: [NSAttributedString.Key: any Sendable] = [:]
}

public struct StyleBuilder {
	public var styles: [String: any Style] = [:]

	public init(block: (inout StyleBuilder) -> Void) {
		block(&self)
	}

	public subscript(_ name: String) -> (any Style)? {
		get {
			styles[name]
		}

		set {
			styles[name] = newValue
		}
	}

	public subscript(_ name: String) -> NSUIColor? {
		get {
			styles[name, default: GenericStyle(name: name)].color
		}

		set {
			styles[name, default: GenericStyle(name: name)].color = newValue
		}
	}

	public subscript(_ name: String) -> Color? {
		get {
			if let color = styles[name, default: GenericStyle(name: name)].color {
				return Color(nsuiColor: color)
			} else {
				return nil
			}
		}

		set {
			if let newValue {
				styles[name, default: GenericStyle(name: name)].color = NSUIColor(newValue)
			}
		}
	}

	public subscript(_ name: String) -> Set<FontTrait> {
		get {
			styles[name, default: GenericStyle(name: name)].traits
		}

		set {
			styles[name, default: GenericStyle(name: name)].traits = newValue
		}
	}

	public mutating func add(_ name: String, attributes: [NSAttributedString.Key: any Sendable]) {
		var style = styles[name, default: GenericStyle(name: name)]

		for (key, value) in attributes {
			style.attributes[key] = value
		}

		styles[name] = style
	}
}
