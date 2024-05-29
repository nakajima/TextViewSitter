//
//  TextView.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI
import Rearrange

class Debouncer {
	@LockAttribute var task: Task<Void, Never>? = nil

	func perform(action: @MainActor @Sendable @escaping () -> Void) {
		task?.cancel()
		task = Task { @MainActor in
			do {
				try await Task.sleep(for: .seconds(0.2))
			} catch {
				return
			}

			if Task.isCancelled {
				return
			}

			action()
		}
	}
}

public class TextView: NSUITextView {
	var isScrollingDisabled = false
	var isSelectionLocked = false
	let touchDebouncer = Debouncer()

	public func handleReplacement(
		for trigger: ReplacerTrigger,
		selection: NSRange,
		before: (() -> Void)? = nil,
		defaultCallback: (() -> Void)? = nil
	) {
		if let handler = ReplacerResolver(trigger: trigger, selection: selection, textView: self).result() {
			performReplacement(handler, selection: selection)
		} else {
			defaultCallback?()
		}
	}

	func performReplacement(
		_ action: ReplacerResult, selection: NSRange,
		before: (() -> Void)? = nil
	) {
		before?()
		action.apply(to: self)
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
		func setSelectedRange(_ range: NSRange) {
			selectedRange = range
		}

		override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
			let location = convert(point, to: coordinateSpace)

			if let textRange = characterRange(at: location),
			   let range = NSRange(textRange, textView: self)
			{
				let position = range.location
				if let handler = ReplacerResolver(trigger: .tap(position), selection: selectedRange, textView: self).result() {
					touchDebouncer.perform {
						self.performReplacement(handler, selection: self.selectedRange)
					}
					return false
				}
			}

			return true
		}
	#endif
}
