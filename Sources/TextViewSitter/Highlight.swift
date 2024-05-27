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
}
