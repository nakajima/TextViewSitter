//
//  TextView.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI
import Rearrange

public enum ReplacerTrigger {
	case characters(String), taskList(Bool)
}

public class TextView: NSUITextView {
	var value: String {
		#if os(macOS)
			string
		#else
			text
		#endif
	}

	public func handleReplacement(for trigger: ReplacerTrigger, selection: NSRange, defaultCallback: () -> Void) {
		let handler: ReplacerResult? = switch trigger {
		case let .characters(characters):
			switch characters {
			case "\r":
				NewlineReplacer().handler(for: trigger, in: self, selection: selection)
			default:
				nil
			}
		case .taskList:
			TaskListReplacer().handler(for: trigger, in: self, selection: selection)
		}

		if let handler {
			handler.apply(to: self)
		} else {
			defaultCallback()
		}
	}

	#if os(macOS)
		override public func keyDown(with event: NSEvent) {
			guard let characters = event.characters else {
				super.keyDown(with: event)
				return
			}

			handleReplacement(for: .characters(characters), selection: selectedRange) {
				super.keyDown(with: event)
			}
		}
	#else
		override public func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
			guard let firstPress = presses.first, let characters = firstPress.key?.characters else {
				super.pressesBegan(presses, with: event)
				return
			}

			handleReplacement(for: .characters(characters), selection: selectedRange) {
				super.pressesBegan(presses, with: event)
			}
		}

		func setSelectedRange(_ range: NSRange) {
			selectedRange = range
		}

		func insertText(_ content: String, replacementRange _: NSRange) {
			insertText(content)
		}
	#endif
}
