//
//  CancelSelectionCommand.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation

struct CancelSelectionCommand: Command {
	func handler(for _: CommandTrigger, in textView: TextView, selection: NSRange) -> CommandResult? {
		textView.setSelectedRange(.init(location: selection.upperBound, length: 0))

		return .ignore
	}
}
