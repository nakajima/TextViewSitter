//
//  Theme.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI

public struct Theme {
	public struct Fonts {
		let theme: Theme

		public func regular() -> NSUIFont {
			theme.fontFamily.regular(ofSize: theme.fontSize)
		}

		public func bold() -> NSUIFont {
			theme.fontFamily.bold(ofSize: theme.fontSize)
		}

		public func italics() -> NSUIFont {
			theme.fontFamily.italics(ofSize: theme.fontSize)
		}
	}

	public static let `default` = Theme(fontFamily: .default, colors: .default)

	public var fontSize: CGFloat
	public var lineSpacing: CGFloat
	public var fontFamily: any FontFamily
	public var colors: ColorSet

	public init(
		fontSize: CGFloat = 16,
		lineSpacing: CGFloat = 4,
		fontFamily: any FontFamily,
		colors: ColorSet
	) {
		self.fontSize = fontSize
		self.lineSpacing = lineSpacing
		self.fontFamily = fontFamily
		self.colors = colors
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
