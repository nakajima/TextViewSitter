//
//  CaretState.swift
//
//
//  Created by Pat Nakajima on 5/26/24.
//

import Foundation
import NSUI

public struct CaretState {
	public let selectedRange: NSRange?
	public let highlights: [Highlight]

	public init() {
		self.selectedRange = nil
		self.highlights = []
	}

	init(selectedRange: NSRange, highlights: [Highlight]) {
		self.selectedRange = selectedRange
		self.highlights = highlights
	}

	public var position: Int {
		selectedRange?.location ?? 0
	}

	private func processIndent(string: String, highlight _: Highlight, in _: NSTextStorage) -> String {
		return string
	}
}
