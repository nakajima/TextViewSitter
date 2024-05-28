//
//  Theme.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI

public struct Theme: Sendable {
	public struct Fonts: Sendable {
		let theme: Theme

		public func font(traits: Set<FontTrait>) -> NSUIFont {
			theme.fontFamily.font(ofSize: theme.fontSize, traits: traits)
		}

		public func regular() -> NSUIFont {
			theme.fontFamily.font(ofSize: theme.fontSize, traits: [])
		}
	}

	public static let `default` = Theme(fontFamily: .default, colors: .default, styles: StyleBuilder.default)

	public var fontSize: CGFloat
	public var lineSpacing: CGFloat
	public var fontFamily: any FontFamily
	public var colors: ColorSet
	public var styles: [String: any Style] = [:]

	public init(
		fontSize: CGFloat = 16,
		lineSpacing: CGFloat = 4,
		fontFamily: any FontFamily,
		colors: ColorSet,
		styles: [String: any Style]
	) {
		self.fontSize = fontSize
		self.lineSpacing = lineSpacing
		self.fontFamily = fontFamily
		self.colors = colors
		self.styles = styles
	}

	public var fonts: Fonts {
		Fonts(theme: self)
	}

	public var typingAttributes: [NSAttributedString.Key: Any] {
		return [
			.font: fonts.regular(),
			.foregroundColor: colors.textColor,
			.paragraphStyle: defaultParagraphStyle,
		]
	}

	public var defaultParagraphStyle: NSParagraphStyle {
		let style = NSMutableParagraphStyle()

		style.lineSpacing = lineSpacing

		return style
	}

	public var letterWidth: CGFloat {
		"_".size(withAttributes: [.font: fonts.regular()]).width
	}
}
