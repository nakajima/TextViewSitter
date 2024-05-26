//
//  Highlight.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI

public struct Highlight: Hashable, Equatable {
	public static func == (lhs: Highlight, rhs: Highlight) -> Bool {
		lhs.name == rhs.name && lhs.range == rhs.range
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(range)
	}

	public var name: String
	public var nameComponents: [String]
	public var range: NSRange
	public var style: [NSAttributedString.Key: Any]
}
