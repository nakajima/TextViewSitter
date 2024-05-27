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
	func regular(ofSize: CGFloat) -> NSUIFont
	func bold(ofSize: CGFloat) -> NSUIFont
	func italics(ofSize: CGFloat) -> NSUIFont
}

public struct FontFamilyDefault: FontFamily {
	public var name = "Default"

	public func regular(ofSize: CGFloat) -> NSUIFont {
		NSUIFont.monospacedSystemFont(ofSize: ofSize, weight: .regular)
	}

	public func bold(ofSize: CGFloat) -> NSUIFont {
		NSUIFont.monospacedSystemFont(ofSize: ofSize, weight: .bold)
	}

	public func italics(ofSize: CGFloat) -> NSUIFont {
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
