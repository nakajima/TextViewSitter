//
//  NewlineCommand.swift
//
//
//  Created by Pat Nakajima on 5/28/24.
//

import Foundation

enum ListMarker {
	case unordered(Substring), ordered(Int), taskList

	var original: String {
		switch self {
		case let .unordered(character):
			"\(character) "
		case let .ordered(int):
			"\(int). "
		case .taskList:
			"- [ ] "
		}
	}

	var output: String {
		switch self {
		case let .unordered(character):
			"\(character) "
		case let .ordered(int):
			"\(int + 1). "
		case .taskList:
			"- [ ] "
		}
	}
}

@MainActor struct NewlineCommand: Command {
	func handler(for _: CommandTrigger, in textView: TextView, selection _: NSRange) -> CommandResult? {
		guard let selectedRange = textView.selectedRanges.first?.rangeValue else {
			return nil
		}

		let currentLineRange = (textView.value as NSString).lineRange(for: selectedRange)
		let currentLine = (textView.value as NSString).substring(with: currentLineRange)

		if let handler = handleList(
			lineRange: currentLineRange,
			line: currentLine,
			selectedRange: textView.selectedRange
		) {
			return handler
		}

		return nil
	}

	private func handleList(
		lineRange: NSRange,
		line: String,
		selectedRange: NSRange
	) -> CommandResult? {
		// TODO: Handle nested lists
		let listMarker: ListMarker? = if line.firstMatch(of: #/^-\s\[[\sx]\]\s/#) != nil {
			.taskList
		} else if let match = line.firstMatch(of: #/^(\d+)\. /#), let int = Int(match.output.1) {
			.ordered(int)
		} else if let match = line.firstMatch(of: #/^([\+\-\*]) /#) {
			.unordered(match.output.1)
		} else {
			nil
		}

		guard let listMarker else {
			return nil
		}

		if listMarker.original.trimmed == line.trimmed {
			return .replace(.init(range: lineRange, content: "\n", postContent: "\n", label: "Leave List", shouldUpdateSelection: true, selectionOffset: -1))
		} else {
			return .insert(.init(range: selectedRange, content: "\n\(listMarker.output)", label: "Add List Item", shouldUpdateSelection: true))
		}
	}
}
