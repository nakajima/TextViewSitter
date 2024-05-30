//
//  SurroundSelectionCommand.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation

struct SurroundSelectionCommand: Command {
	func handler(for trigger: CommandTrigger, in textView: TextView, selection: NSRange) -> CommandResult? {
		guard selection.length > 0 else {
			return nil
		}

		guard case let .characters(characters, _) = trigger else {
			return nil
		}

		guard let existingString = textView.string[selection] else {
			return nil
		}

		let open = characters
		let close: String = [
			"{": "}",
			"[": "]",
			"(": ")",
		][open] ?? open

		return .replace(.init(range: selection, content: "\(open)\(existingString)\(close)", label: "Wrap Selection", shouldUpdateSelection: true))
	}
}
