//
//  TextView.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI
import Rearrange
import TextStory

public class TextView: NSUITextView {
	var isScrollingDisabled = false
	var isSelectionLocked = false
	let touchThrottler = Throttler()

	public func handleCommand(
		for trigger: CommandTrigger,
		selection: NSRange,
		before _: (() -> Void)? = nil,
		defaultCallback: (() -> Void)? = nil
	) {
		if let handler = CommandResolver(trigger: trigger, selection: selection, textView: self).result() {
			performReplacement(handler, selection: selection)
		} else {
			defaultCallback?()
		}
	}

	func performReplacement(
		_ action: CommandResult, selection _: NSRange,
		before: (() -> Void)? = nil
	) {
		before?()
		action.apply(to: self)
	}

	#if os(macOS)
		override public func keyDown(with event: NSEvent) {
			guard let characters = event.charactersIgnoringModifiers else {
				print("no characters? \(event)")
				super.keyDown(with: event)
				return
			}

			handleCommand(for: .characters(characters, event.modifierFlags), selection: selectedRange, defaultCallback: {
				super.keyDown(with: event)
			})
		}

		override public func mouseDown(with event: NSEvent) {
			// Get the location of the mouse click in the view's coordinate system
			let location = convert(event.locationInWindow, from: nil)

			// Get the character index for the mouse click location
			let position = characterIndexForPoint(location: location)

			handleCommand(for: .tap(position), selection: selectedRange(), defaultCallback: { super.mouseDown(with: event) })
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
		override public var keyCommands: [UIKeyCommand]? {
			return [
				UIKeyCommand(
					title: "Expand Selection",
					image: nil,
					action: #selector(keyCommand(_:)),
					input: "w",
					modifierFlags: [.control],
					propertyList: nil,
					alternates: [],
					discoverabilityTitle: "Expand Selection",
					attributes: [],
					state: .on
				),
				UIKeyCommand(
					title: "Cancel Selection",
					image: nil,
					action: #selector(keyCommand(_:)),
					input: "c",
					modifierFlags: [.control],
					propertyList: nil,
					alternates: [],
					discoverabilityTitle: "Cancel Selection",
					attributes: [],
					state: .on
				),
				UIKeyCommand(
					title: "Jump to Next Word",
					image: nil,
					action: #selector(keyCommand(_:)),
					input: "f",
					modifierFlags: [.alternate],
					propertyList: nil,
					alternates: [],
					discoverabilityTitle: "Jump to Next Word",
					attributes: [],
					state: .on
				),
				UIKeyCommand(
					title: "Jump to Previous Word",
					image: nil,
					action: #selector(keyCommand(_:)),
					input: "b",
					modifierFlags: [.alternate],
					propertyList: nil,
					alternates: [],
					discoverabilityTitle: "Jump to Previous Word",
					attributes: [],
					state: .on
				),
			]
		}

		@objc func keyCommand(_ keyCommand: UIKeyCommand) {
			handleCommand(for: .characters(keyCommand.input ?? "", keyCommand.modifierFlags), selection: selectedRange)
		}

		func setSelectedRange(_ range: NSRange) {
			selectedRange = range
		}

		override public func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
			let location = convert(point, to: coordinateSpace)

			if let textRange = characterRange(at: location),
			   let range = NSRange(textRange, textView: self)
			{
				let position = range.location
				if let handler = CommandResolver(trigger: .tap(position), selection: selectedRange, textView: self).result() {
					touchThrottler.throttle {
						self.performReplacement(handler, selection: self.selectedRange)
					}
					return false
				}
			}

			return true
		}
	#endif
}
