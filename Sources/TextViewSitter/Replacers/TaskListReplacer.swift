//
//  TaskListReplacer.swift
//
//
//  Created by Pat Nakajima on 5/28/24.
//

import Foundation

struct TaskListReplacer: Replacer {
	func handler(for _: ReplacerTrigger, in textView: TextView, selection: NSRange) -> ReplacerResult? {
		let currentLineRange = (textView.value as NSString).lineRange(for: selection)
		let currentLine = (textView.value as NSString).substring(with: currentLineRange)

		let replacementRange = NSRange(location: currentLineRange.location + 3, length: 1)

		if currentLine.starts(with: "- [ ]") {
			return .replace(range: replacementRange, with: "x", label: "Mark Task Item Complete")
		} else {
			return .replace(range: replacementRange, with: " ", label: "Mark Task Item Incomplete")
		}
	}
}
