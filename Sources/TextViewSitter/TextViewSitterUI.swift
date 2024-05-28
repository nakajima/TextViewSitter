//
//  TextViewSitterUI.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI
import Observation
import SwiftUI

public protocol TextViewSitterTextModel: AnyObject, Equatable {
	var text: String { get set }
	@MainActor func didChange(text: String)
}

public extension TextViewSitterTextModel {
	func didChange(text: String) {
		self.text = text
	}
}

public struct TextViewSitterUI<Model: TextViewSitterTextModel>: NSUIViewControllerRepresentable {
	public typealias NSUIViewControllerType = TextViewSitterController<Model>

	@Environment(\.isFocused) var isFocused

	var model: Model

	var caretState: Binding<CaretState>?
	var theme: Theme

	public init(model: Model, caretState: Binding<CaretState>? = nil, theme: Theme) {
		self.model = model
		self.caretState = caretState
		self.theme = theme
	}

	public func makeNSUIViewController(context _: Context) -> TextViewSitterController<Model> {
		TextViewSitterController(
			model: model,
			theme: theme,
			caretChangeCallback: { caret in
				self.caretState?.wrappedValue = caret
			}
		)
	}

	public func updateNSUIViewController(_ controller: TextViewSitterController<Model>, context _: Context) {
		if theme != controller.theme {
			controller.load(theme: theme)
		}

		// Only update controller text content when we're showing a different model.
		if controller.model != model {
			controller.load(model: model)
		}

		if isFocused {
			controller.focus()
		}
	}
}
