//
//  ReplacerResolver.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation
import NSUI

public enum ReplacerTrigger {
	// When the user types something
	case characters(String)

	// When the user taps or clicks something
	case tap(Int)
}

@MainActor struct ReplacerResolver {
	var trigger: ReplacerTrigger
	var selection: NSRange
	var textView: TextView

	func result() -> ReplacerResult? {
		switch trigger {
		case let .characters(string):
			resolveCharacters(characters: string)
		case let .tap(position):
			resolveTap(position: position)
		}
	}

	private func resolveCharacters(characters: String) -> ReplacerResult? {
		switch characters {
		case "\r", "\n":
			NewlineReplacer().handler(for: trigger, in: textView, selection: selection)
		default:
			nil
		}
	}

	private func resolveTap(position: Int) -> ReplacerResult? {
		let attributes: [NSAttributedString.Key: Any] = textView.nsuiTextStorage?.attributes(at: position, effectiveRange: nil) ?? [:]

		if let isTaskListMarker = attributes[.isTaskListMarker] as? Bool, isTaskListMarker {
			return TaskListReplacer().handler(for: trigger, in: textView, selection: selection)
		}

		return nil
	}
}
