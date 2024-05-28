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
		selectedRange = nil
		highlights = []
	}

	init(selectedRange: NSRange, highlights: [Highlight]) {
		self.selectedRange = selectedRange
		self.highlights = highlights
	}

	public var position: Int {
		selectedRange?.location ?? 0
	}

	func suggestedIndent(in storage: NSTextStorage) -> IndentHint? {
		var result: IndentHint? = nil

		for highlight in highlights {
			if let indentHint = highlight.style[.indentHint] as? IndentHint {
				print("hint!: \(indentHint)")
				switch indentHint {
				case let .add(insertion):
					// Rewrite insertion if needed (like if we're in an ordered list)
					result = .add(processIndent(string: insertion, highlight: highlight, in: storage))
				case .replace(_, _):
					result = indentHint
				}

				break
			}
		}

		return result
	}

	private func processIndent(string: String, highlight: Highlight, in storage: NSTextStorage) -> String {
		return string
	}
}
