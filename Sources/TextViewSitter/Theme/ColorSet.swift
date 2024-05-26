//
//  ColorSet.swift
//
//
//  Created by Pat Nakajima on 5/25/24.
//

import Foundation
import NSUI
import SwiftUI

public struct ColorSet {
	public let textColor: NSUIColor
	public let linkColor: NSUIColor
	public let backgroundColor: NSUIColor

	public init(textColor: NSUIColor, linkColor: NSUIColor, backgroundColor: NSUIColor) {
		self.textColor = textColor
		self.linkColor = linkColor
		self.backgroundColor = backgroundColor
	}
}

public extension ColorSet {
	static let `default` = ColorSet(
		textColor: NSColor(Color.primary),
		linkColor: NSUIColor.controlAccentColor,
		backgroundColor: .systemBackground
	)
}
