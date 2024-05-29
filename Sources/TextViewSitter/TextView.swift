//
//  TextView.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI
import Rearrange

public class TextView: NSUITextView {
	var isScrollingDisabled = false

	// TODO: Clean this up
	public func handleReplacement(for trigger: ReplacerTrigger, selection: NSRange, defaultCallback: () -> Void) {
		if let handler = ReplacerResolver(trigger: trigger, selection: selection, textView: self).result() {
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

		override public func mouseDown(with event: NSEvent) {
			// Get the location of the mouse click in the view's coordinate system
			let location = convert(event.locationInWindow, from: nil)

			// Get the character index for the mouse click location
			let position = characterIndexForPoint(location: location)

			handleReplacement(for: .tap(position), selection: selectedRange()) { super.mouseDown(with: event) }
		}

		private func characterIndexForPoint(location: NSPoint) -> Int {
			guard let layoutManager = layoutManager, let textContainer = textContainer else {
				return NSNotFound
			}

			// Adjust the location point to account for the text container's origin
			let textContainerOffset = NSPoint(x: textContainerInset.width, y: textContainerInset.height)
			let locationInTextContainer = NSPoint(x: location.x - textContainerOffset.x, y: location.y - textContainerOffset.y)

			// Get the character index at the clicked point
			let glyphIndex = layoutManager.glyphIndex(for: locationInTextContainer, in: textContainer)
			let characterIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)

			return characterIndex
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
	#endif
}
