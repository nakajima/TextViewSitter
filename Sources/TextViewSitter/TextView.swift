//
//  TextView.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI

enum CompletionType {
	case newlineWith(String), replaceLineWith(String), unhandled
}

public class TextView: NSUITextView {
	var value: String {
		#if os(macOS)
			string
		#else
			text
		#endif
	}

	public func handleReplacement(for characters: String, defaultCallback: () -> Void) {
		let handler: ReplacerResult? = switch characters {
		case "\r":
			NewlineReplacer().handler(for: characters, in: self)
		default:
			nil
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

			handleReplacement(for: characters) {
				super.keyDown(with: event)
			}
		}
	#else
		override public func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
			guard let firstPress = presses.first, let characters = firstPress.key?.characters else {
				super.pressesBegan(presses, with: event)
				return
			}

			handleReplacement(for: characters) {
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
