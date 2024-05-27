//
//  NSRange+Helpers.swift
//
//
//  Created by Pat Nakajima on 5/25/24.
//

import Foundation
import NSUI

extension NSRange {
	init(textStorage: NSTextStorage) {
		self.init(location: 0, length: textStorage.length)
	}

	init(nsAttributedString: NSAttributedString) {
		self.init(location: 0, length: nsAttributedString.length)
	}

	func contains(_ range: NSRange) -> Bool {
		return range.lowerBound >= lowerBound && range.upperBound >= upperBound
	}

	func clamped(to bounds: NSRange) -> NSRange {
		let lowerBound = Swift.max(lowerBound, 0)
		let upperBound = Swift.min(upperBound, bounds.upperBound)
		return NSRange(location: lowerBound, length: upperBound - lowerBound)
	}
}
