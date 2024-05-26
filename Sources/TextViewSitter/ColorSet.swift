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

	public init(textColor: NSUIColor, linkColor: NSUIColor) {
		self.textColor = textColor
		self.linkColor = linkColor
	}
}

public extension ColorSet {
	static let `default` = ColorSet(
		textColor: NSColor(Color.primary),
		linkColor: NSUIColor.controlAccentColor
	)
}
