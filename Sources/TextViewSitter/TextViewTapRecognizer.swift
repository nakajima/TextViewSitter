//
//  File 2.swift
//
//
//  Created by Pat Nakajima on 5/28/24.
//

#if canImport(UIKit)
	import Foundation
	import UIKit

	class TextViewTapRecognizer<T: TextViewSitterTextModel>: UITapGestureRecognizer, UIGestureRecognizerDelegate {
		let controller: TextViewSitterController<T>

		init(controller: TextViewSitterController<T>) {
			self.controller = controller

			super.init(target: controller, action: nil)
			self.cancelsTouchesInView = true

			self.delegate = self
		}

		func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
			let location = gesture.location(in: controller.textView)
			if let textRange = controller.textView.characterRange(at: location),
			   let range = NSRange(textRange, textView: controller.textView)
			{
				let position = range.location
				let highlights = controller.highlighter.highlights(at: position)
				let highlightNames = Set(highlights.map(\.name))
				if highlightNames.contains("markup.list.unchecked") || highlightNames.contains("markup.list.checked") {
					let selectionToRestore = controller.textView.selectedRange
					controller.textView.handleReplacement(for: .taskList(!highlightNames.contains("markup.list.checked")), selection: .init(location: position, length: 0)) {}
					controller.textView.selectedRange = selectionToRestore
					return true
				}

				return false
			} else {
				return false
			}
		}
	}

#endif
