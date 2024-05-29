//
//  ReplacerResult.swift
//
//
//  Created by Pat Nakajima on 5/28/24.
//

import Foundation

enum ReplacerResult {
	case insert(content: String, at: NSRange, label: String),
	     replace(range: NSRange, with: String, label: String),
	     ignore

	@MainActor func apply(to textView: TextView) {
		switch self {
		case .ignore:
			()
		case let .insert(content, range, label):
			textView.undoManager!.registerUndo(withTarget: textView) { target in
				if let replacementRange = range.shifted(endBy: -content.count) {
					#if os(macOS)
						target.replaceCharacters(in: replacementRange, with: "")
					#else
						if let range = textView.textRange(with: replacementRange) {
							target.replace(range, withText: "")
						}
					#endif
				}
			}

			textView.insertText(content, replacementRange: range)
			textView.undoManager!.setActionName(label)
		case let .replace(range, content, label):
			let currentText = (textView.value as NSString).substring(with: range)

			#if os(macOS)
				textView.undoManager!.registerUndo(withTarget: textView) { target in
					if let replacementRange = range.shifted(endBy: -currentText.count) {
						target.replaceCharacters(in: replacementRange, with: currentText)
						target.setSelectedRange(NSRange(location: range.upperBound, length: 0))
					}
				}

				textView.replaceCharacters(in: range, with: currentText)
			#else
				textView.undoManager!.registerUndo(withTarget: textView) { target in
					let replacementRange = range.shifted(endBy: -currentText.count)!
					let replacementTextRange = textView.textRange(with: replacementRange)!

					target.replace(replacementTextRange, withText: "")
					target.setSelectedRange(NSRange(location: range.upperBound, length: 0))
				}

				if let textRange = textView.textRange(with: range) {
					textView.replace(textRange, withText: content)
				}
			#endif

			textView.undoManager!.setActionName(label)
		}
	}
}
