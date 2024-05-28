//
//  FontFamily.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI

public protocol FontFamily: Sendable {
	var name: String { get }

	func font(ofSize: CGFloat, traits: Set<FontTrait>) -> NSUIFont
}

public struct FontFamilyDefault: FontFamily {
	public var name = "SF Mono"

	public func font(ofSize: CGFloat, traits: Set<FontTrait>) -> NSUIFont {
		switch traits.sorted() {
		case [.bold]:
			bold(ofSize: ofSize)
		case [.italic]:
			italics(ofSize: ofSize)
		case [.bold, .italic]:
			bold(ofSize: ofSize).italics(ofSize: ofSize)
		default:
			regular(ofSize: ofSize)
		}
	}

	private func regular(ofSize: CGFloat) -> NSUIFont {
		NSUIFont.monospacedSystemFont(ofSize: ofSize, weight: .regular)
	}

	private func bold(ofSize: CGFloat) -> NSUIFont {
		NSUIFont.monospacedSystemFont(ofSize: ofSize, weight: .bold)
	}

	private func italics(ofSize: CGFloat) -> NSUIFont {
		NSUIFont.monospacedSystemFont(ofSize: ofSize, weight: .regular).italics(ofSize: ofSize)
	}

	public init() {}
}

public extension FontFamily where Self == FontFamilyDefault {
	static var `default`: FontFamilyDefault { FontFamilyDefault() }
}

public extension NSUIFont {
	func italics(ofSize: CGFloat) -> NSUIFont {
		let descriptor = NSUIFont.monospacedSystemFont(ofSize: ofSize, weight: .regular).fontDescriptor.nsuiWithSymbolicTraits(.traitItalic) ?? NSUIFont.monospacedSystemFont(ofSize: ofSize, weight: .regular).fontDescriptor
		return NSUIFont(nsuiDescriptor: descriptor, size: ofSize) ?? NSUIFont.monospacedSystemFont(ofSize: ofSize, weight: .regular)
	}
}
