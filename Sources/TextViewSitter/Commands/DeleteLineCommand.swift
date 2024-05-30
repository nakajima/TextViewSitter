//
//  DeleteLineCommand.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation

struct DeleteLineCommand: Command {
	func handler(for _: CommandTrigger, in textView: TextView, selection _: NSRange) -> CommandResult? {
		guard let selectedRange = textView.selectedRanges.first?.rangeValue else {
			return nil
		}

		let currentLineRange = (textView.value as NSString).lineRange(for: selectedRange)

		return .replace(.init(range: currentLineRange, content: "", label: "Delete Line", shouldUpdateSelection: false))
	}
}
