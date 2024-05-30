//
//  TaskListCommand.swift
//
//
//  Created by Pat Nakajima on 5/28/24.
//

import Foundation
import NSUI

struct TaskListCommand: Command {
	func handler(for trigger: CommandTrigger, in textView: TextView, selection _: NSRange) -> CommandResult? {
		guard case let .tap(position) = trigger else {
			return nil
		}

		let currentLineRange = (textView.value as NSString).lineRange(for: NSRange(location: position, length: 0))
		let currentLine = (textView.value as NSString).substring(with: currentLineRange)

		let replacementRange = NSRange(location: currentLineRange.location + 3, length: 1)

		if currentLine.starts(with: "- [ ]") {
			return .replace(.init(range: replacementRange, content: "x", label: "Mark Task Item Complete", shouldUpdateSelection: false))
		} else {
			return .replace(.init(range: replacementRange, content: " ", label: "Mark Task Item Incomplete", shouldUpdateSelection: false))
		}
	}
}
