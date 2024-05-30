//
//  ExpandSelectionCommand.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation
import NaturalLanguage

extension NSString {
	func wordRange(at range: NSRange) -> NSRange {
		// Ensure we have a valid range to work with
		let length = self.length
		guard range.location <= length else { return NSRange(location: NSNotFound, length: 0) }

		// Determine the start and end of the word
		let wordRange = rangeOfCharacter(from: .whitespacesAndNewlines.inverted, options: [], range: NSRange(location: range.location, length: length - range.location))

		let start = rangeOfCharacter(from: .whitespacesAndNewlines.inverted, options: .backwards, range: NSRange(location: 0, length: wordRange.location)).location
		let end = rangeOfCharacter(from: .whitespacesAndNewlines.inverted, options: [], range: NSRange(location: wordRange.location, length: length - wordRange.location)).upperBound

		return NSRange(location: start, length: end - start)
	}
}

struct ExpandSelectionCommand: Command {
	func handler(for _: CommandTrigger, in textView: TextView, selection: NSRange) -> CommandResult? {
		// Get the full text from the text storage
		let text = textView.value

		let cursorPosition = selection.location

		// Check if cursorPosition is within the text length
		guard cursorPosition < text.count else { return nil }

		var units: [NLTokenUnit] = [.document, .paragraph, .sentence, .word]

		while !units.isEmpty {
			guard let unit = units.popLast() else { break }

			// Use NLTokenizer to determine the range of the unit at the cursor position
			let tokenizer = NLTokenizer(unit: unit)
			tokenizer.string = text

			let tokenRange = tokenizer.tokenRange(at: text.index(text.startIndex, offsetBy: cursorPosition))

			// Convert tokenRange to NSRange
			let proposedRange = NSRange(tokenRange, in: text as String)

			if proposedRange.length > selection.length {
				// Set the selected range to the proposed range
				textView.setSelectedRange(proposedRange)
				break
			}
		}

		return .ignore
	}
}
