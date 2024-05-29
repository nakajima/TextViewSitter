//
//  TaskListReplacer.swift
//
//
//  Created by Pat Nakajima on 5/28/24.
//

import Foundation
import NSUI

struct TaskListReplacer: Replacer {
	func handler(for trigger: ReplacerTrigger, in textView: TextView, selection _: NSRange) -> ReplacerResult? {
		guard case let .tap(position) = trigger else {
			return nil
		}

		let currentLineRange = (textView.value as NSString).lineRange(for: NSRange(location: position, length: 0))
		let currentLine = (textView.value as NSString).substring(with: currentLineRange)

		let replacementRange = NSRange(location: currentLineRange.location + 3, length: 1)

		if currentLine.starts(with: "- [ ]") {
			return .replace(range: replacementRange, with: "x", label: "Mark Task Item Complete")
		} else {
			return .replace(range: replacementRange, with: " ", label: "Mark Task Item Incomplete")
		}
	}
}
