//
//  CommandResult.swift
//
//
//  Created by Pat Nakajima on 5/28/24.
//

import Foundation
import TextStory

struct CommandMutation {
	var range: NSRange
	var content: String
	var label: String
	var shouldUpdateSelection: Bool
}

enum CommandResult {
	case insert(CommandMutation),
	     replace(CommandMutation),
	     ignore

	@MainActor func apply(to textView: TextView) {
		switch self {
		case .ignore:
			()
		case let .insert(replacer):
			textView.undoManager!.registerUndo(withTarget: textView) { target in
				if let replacementRange = replacer.range.shifted(endBy: -replacer.content.count) {
					#if os(macOS)
						target.replaceCharacters(in: replacementRange, with: "")
					#else
						if let range = textView.textRange(with: replacementRange) {
							target.replace(range, withText: "")
						}
					#endif
				}
			}

			textView.insertText(replacer.content)
			textView.undoManager!.setActionName(replacer.label)

			if replacer.shouldUpdateSelection {
				textView.setSelectedRange(.init(location: replacer.range.upperBound + replacer.content.count, length: 0))
			}
		case let .replace(replacer):
			let currentText = (textView.value as NSString).substring(with: replacer.range)

			#if os(macOS)
				textView.undoManager!.registerUndo(withTarget: textView) { target in
					if let replacementRange = replacer.range.shifted(endBy: -currentText.count) {
						target.replaceCharacters(in: replacementRange, with: currentText)
					}
				}

				textView.replaceCharacters(in: replacer.range, with: replacer.content)
			#else
				textView.undoManager!.registerUndo(withTarget: textView) { target in
					let replacementRange = replacer.range.shifted(endBy: -currentText.count)!

					target.replaceString(in: replacementRange, with: currentText)

					if replacer.shouldUpdateSelection {
						textView.setSelectedRange(.init(location: replacementRange.location + currentText.count - 1, length: 0))
					}
				}

				textView.replaceString(in: replacer.range, with: replacer.content)
			#endif

			textView.undoManager!.setActionName(replacer.label)

			if replacer.shouldUpdateSelection {
				textView.setSelectedRange(.init(location: replacer.range.location + replacer.content.count, length: 0))
			}
		}
	}
}
