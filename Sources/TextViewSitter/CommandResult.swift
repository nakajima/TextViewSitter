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
	var postContent: String?
	var label: String
	var shouldUpdateSelection: Bool
	var selectionOffset = 0
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
			let undoRange = NSRange(location: replacer.range.location, length: replacer.content.count)

			#if os(macOS)
				textView.undoManager!.registerUndo(withTarget: textView) { target in
					target.replaceCharacters(in: undoRange, with: currentText)

					if replacer.shouldUpdateSelection {
						textView.setSelectedRange(NSRange(location: replacer.range.location + currentText.count + replacer.selectionOffset, length: 0))
					}
				}

				textView.replaceCharacters(in: replacer.range, with: replacer.content)
			#else
				textView.undoManager!.registerUndo(withTarget: textView) { target in
					target.replaceString(in: undoRange, with: currentText)

					if replacer.shouldUpdateSelection {
						textView.setSelectedRange(.init(location: undoRange.location + currentText.count - 1, length: 0))
					}
				}

				textView.replaceString(in: replacer.range, with: replacer.content)
			#endif

			textView.undoManager!.setActionName(replacer.label)

			let lastLocation = replacer.range.location + replacer.content.count

			if let postContent = replacer.postContent {
				#if os(macOS)
				textView.insertText(postContent, replacementRange: .init(location: lastLocation, length: 0))
				#else
				textView.insertString(postContent, at: lastLocation)
				#endif
			}

			if replacer.shouldUpdateSelection {
				textView.setSelectedRange(.init(location: lastLocation, length: 0))
			}
		}
	}
}
