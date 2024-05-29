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
	public let allowsAutoIndentation: Bool
	public let allowsAutoFormatting: Bool

	public init() {
		self.selectedRange = nil
		self.highlights = []
		self.allowsAutoIndentation = false
		self.allowsAutoFormatting = true
	}

	init(selectedRange: NSRange, highlights: [Highlight], allowsAutoIndentation: Bool, allowsAutoFormatting: Bool) {
		self.selectedRange = selectedRange
		self.highlights = highlights
		self.allowsAutoIndentation = allowsAutoIndentation
		self.allowsAutoFormatting = allowsAutoFormatting
	}

	public var position: Int {
		selectedRange?.location ?? 0
	}

	private func processIndent(string: String, highlight _: Highlight, in _: NSTextStorage) -> String {
		return string
	}
}
