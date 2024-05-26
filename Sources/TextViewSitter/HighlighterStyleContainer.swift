//
//  HighlighterStyleContainer.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation

public struct HighlighterStyleContainer {
	var styles: [any HighlighterStyle]
	var styleMap: [String: any HighlighterStyle]

	public init(styles: [any HighlighterStyle]) {
		self.styles = styles
		self.styleMap = styles.reduce(into: [:]) { result, style in
			result[style.name] = style
		}
	}

	public func style(for name: String) -> (any HighlighterStyle)? {
		styleMap[name]
	}
}
