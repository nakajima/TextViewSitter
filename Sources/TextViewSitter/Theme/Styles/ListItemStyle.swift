//
//  ListItemStyle.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation
import NSUI

public struct ListItemStyle: Style {
	public var color: NSUIColor? = nil
	public var traits: Set<FontTrait> = []
	public var attributes: [NSAttributedString.Key: any Sendable] = [:]

	public init() {}

	public func refinement(for range: NSRange, theme: Theme, in storage: NSTextStorage) -> [NSAttributedString.Key: any Sendable] {
		let paragraphStyle = NSMutableParagraphStyle()

		var indentationLevel: CGFloat = 0

		if let line = storage.string[range] {
			let pattern = #/(\- \[[x ]\] |[\-\*\+]\ |\d+\. )/#

			if let match = line.firstMatch(of: pattern) {
				indentationLevel = CGFloat(match.output.1.count)
			}

			// Indent for the first line
			paragraphStyle.firstLineHeadIndent = 0

			// Indent for the wrapped lines
			paragraphStyle.headIndent = theme.letterWidth * indentationLevel

			paragraphStyle.lineSpacing = theme.lineSpacing
		}

		return [
			.paragraphStyle: paragraphStyle as NSParagraphStyle,
		]
	}
}
