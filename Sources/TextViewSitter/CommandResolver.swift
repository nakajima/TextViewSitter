//
//  CommandResolver.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation
import NSUI

public enum CommandTrigger {
	// When the user types something
	case characters(String, NSUIModifierFlags)

	// When the user taps or clicks something
	case tap(Int)
}

extension NSUIModifierFlags {
	func contains(members: Self.Element...) -> Bool {
		for member in members {
			if !contains(member) {
				return false
			}
		}

		return true
	}
}

@MainActor struct CommandResolver {
	var trigger: CommandTrigger
	var selection: NSRange
	var textView: TextView

	func result() -> CommandResult? {
		switch trigger {
		case let .characters(string, modifiers):
			resolveCharacters(characters: string, modifiers: modifiers)
		case let .tap(position):
			resolveTap(position: position)
		}
	}

	// TODO: Make these configurable
	private func resolveCharacters(characters: String, modifiers: NSUIModifierFlags) -> CommandResult? {
		print(characters, modifiers.contains(members: .control, .shift), modifiers.contains(.control), modifiers.contains(.shift))
		return switch characters {
		case "\r", "\n":
			NewlineCommand().handler(for: trigger, in: textView, selection: selection)
		case #"""#, "'", "{", "[", "(":
			SurroundSelectionCommand().handler(for: trigger, in: textView, selection: selection)
		case "K" where modifiers.contains(.control):
			DeleteLineCommand().handler(for: trigger, in: textView, selection: selection)
		case "w" where modifiers.contains(.control):
			ExpandSelectionCommand().handler(for: trigger, in: textView, selection: selection)
		case "c" where modifiers.contains(.control):
			CancelSelectionCommand().handler(for: trigger, in: textView, selection: selection)
		case "f" where modifiers.contains(.option):
			JumpWordCommand(direction: .next).handler(for: trigger, in: textView, selection: selection)
		case "b" where modifiers.contains(.option):
			JumpWordCommand(direction: .previous).handler(for: trigger, in: textView, selection: selection)
		default:
			nil
		}
	}

	private func resolveTap(position: Int) -> CommandResult? {
		if textView.string.isEmpty {
			return nil
		}

		let attributes: [NSAttributedString.Key: Any] = textView.nsuiTextStorage?.attributes(at: position, effectiveRange: nil) ?? [:]

		if let isTaskListMarker = attributes[.isTaskListMarker] as? Bool, isTaskListMarker {
			return TaskListCommand().handler(for: trigger, in: textView, selection: selection)
		}

		return nil
	}
}
