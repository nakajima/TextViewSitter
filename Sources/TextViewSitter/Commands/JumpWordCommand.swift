//
//  JumpWordCommand.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation
import NaturalLanguage

struct JumpWordCommand: Command {
	enum Direction {
		case next, previous
	}

	var direction: Direction

	init(direction: Direction) {
		self.direction = direction
	}

	func handler(for _: CommandTrigger, in textView: TextView, selection: NSRange) -> CommandResult? {
		let text = textView.value
		let cursorPosition = selection.location

		// Use NLTokenizer to determine the range of the unit at the cursor position
		let tokenizer = NLTokenizer(unit: .word)
		tokenizer.string = text

		let currentIndex = text.index(text.startIndex, offsetBy: cursorPosition)
		var resultIndex = currentIndex

		if direction == .next {
			tokenizer.enumerateTokens(in: currentIndex ..< text.endIndex) { tokenRange, _ in
				if tokenRange.lowerBound > currentIndex {
					resultIndex = tokenRange.lowerBound
					return false // Stop enumeration
				}
				return true // Continue enumeration
			}
		} else {
			tokenizer.enumerateTokens(in: text.startIndex ..< currentIndex) { tokenRange, _ in
				if tokenRange.upperBound < currentIndex {
					resultIndex = tokenRange.lowerBound
				}
				return true
			}

			// If we're already at the earliest token but
			if resultIndex.utf16Offset(in: text) == selection.lowerBound, selection.lowerBound > 0 {
				resultIndex = text.startIndex
			}
		}

		// Convert nextIndex to NSRange location
		let nextCursorPosition = text.utf16.distance(from: text.utf16.startIndex, to: resultIndex.samePosition(in: text.utf16)!)

		textView.setSelectedRange(NSRange(location: nextCursorPosition, length: 0))

		return .ignore
	}
}
