//
//  Highlight.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI
import SwiftTreeSitter

public struct Highlight: Hashable, Equatable {
	public static func == (lhs: Highlight, rhs: Highlight) -> Bool {
		lhs.name == rhs.name && lhs.range == rhs.range
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(range)
	}

	public let name: String
	public let language: String
	public let nodeType: String?
	public let nameComponents: [String]
	public let range: NSRange
	public let style: [NSAttributedString.Key: Any]

	func updating(to theme: Theme, in storage: NSTextStorage) -> Highlight {
		if let style = theme.styles[name] {
			let updated = Highlight(
				name: name,
				language: language,
				nodeType: nodeType,
				nameComponents: nameComponents,
				range: range,
				style: style.attributes(for: range, theme: theme, in: storage)
			)

			return updated
		}

		return self
	}
}
