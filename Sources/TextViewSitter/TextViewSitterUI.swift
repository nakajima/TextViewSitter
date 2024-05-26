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

	public init(text: Binding<String>) {
		_text = text
	}

	@Observable public class Coordinator {
		var text: String
		var controller: TextViewSitterController!

		init(text: String) {
			self.text = text
			self.controller = TextViewSitterController(
				text: text,
				styles: StyleBuilder.default, // TODO: Make this configurable
				textChangeCallback: { text in
					print("textChangeCallback: \(text)")
					self.text = text
				}
			)
		}
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(text: text)
	}

	public func makeNSUIViewController(context: Context) -> TextViewSitterController {
		context.coordinator.controller
	}

	public func updateNSUIViewController(_: TextViewSitterController, context: Context) {
		context.coordinator.controller.load(text: text)
	}
}
