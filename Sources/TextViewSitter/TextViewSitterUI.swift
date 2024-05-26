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

public struct TreeSitterUI: NSUIViewControllerRepresentable {
	@Binding var text: String
	var theme: Theme

	public init(text: Binding<String>, theme: Theme) {
		self._text = text
		self.theme = theme
	}

	@Observable public class Coordinator {
		var text: String
		var controller: TextViewSitterController!

		init(text: String, theme: Theme) {
			self.text = text
			self.controller = TextViewSitterController(
				text: text,
				styles: StyleBuilder.default, // TODO: Make this configurable
				theme: theme,
				textChangeCallback: { text in
					self.text = text
				}
			)
		}
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(text: text, theme: theme)
	}

	public func makeNSUIViewController(context: Context) -> TextViewSitterController {
		context.coordinator.controller
	}

	public func updateNSUIViewController(_: TextViewSitterController, context: Context) {
		context.coordinator.controller.load(text: text, theme: theme)
	}
}
