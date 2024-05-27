//
//  EditorView.swift
//  TextViewSitterExample
//
//  Created by Pat Nakajima on 5/26/24.
//

import Foundation
import SwiftUI
import TextViewSitter

struct EditorView: View {
	@State private var theme = Theme.default
	@State private var isPreviewing = false
	@State private var caret: CaretState = CaretState()

	@Bindable var model: TextModel

	var body: some View {
		TextViewSitterUI(model: model, caretState: $caret, theme: theme)
			.toolbar {
				Button("Smaller") {
					if theme.fontSize > 8 {
						theme.fontSize -= 8
					}
				}
				Button("Bigger") {
					theme.fontSize += 8
				}
				Button("Preview") {
					isPreviewing.toggle()
				}.sheet(isPresented: $isPreviewing) {
					ScrollView {
						VStack(alignment: .leading) {
							Text(try! AttributedString(markdown: model.text))
							Button("Done") {
								isPreviewing = false
							}
						}
						.frame(minWidth: 200, minHeight: 200)
					}
					.padding()
					.background(.ultraThinMaterial)
				}
			}
			.safeAreaInset(edge: .bottom) {
				HStack {
					VStack(alignment: .leading, spacing: 4) {
						HStack {
							Text("Position:")
							Text(caret.position, format: .number)
								.fontDesign(.monospaced)
						}
						HStack {
							Text("Languages:")
							summarize(\.language)
						}
					}
					Spacer()
					VStack(alignment: .trailing, spacing: 4) {
						HStack {
							Text("Nodes:")
							summarize(\.nodeType)
						}
						HStack {
							Text("Highlights:")
							summarize(\.name)
						}
					}
				}
				.padding(.bottom, 12)
				.padding(.horizontal)
				.padding(.top, 2)
			}
	}

	func summarize(_ keyPath: PartialKeyPath<Highlight>) -> some View {
		let items = Set(caret.highlights.compactMap {
			switch $0[keyPath: keyPath] {
			case let value as String:
				return value
			case let value as Optional<String>:
				return value ?? nil
			default:
				return nil
			}
		}).sorted()

		return ForEach(Array(items), id: \.self) { item in
			Text(item)
				.fontDesign(.monospaced)
				.padding(.horizontal, 4)
				.background(.background)
		}
	}
}
