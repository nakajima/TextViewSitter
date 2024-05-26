//
//  ContentView.swift
//  TextViewSitterExample
//
//  Created by Pat Nakajima on 5/24/24.
//

import Observation
import SwiftData
import SwiftUI
import TextViewSitter

@Observable
class TextModel: TextViewSitterTextModel {
	var id = UUID()
	var text: String

	init(text: String) {
		self.text = text
	}
}

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
					Spacer()
					Text("Position: \(caret.position)")
					Text("Highlights: \(caret.highlights.map(\.name))")
				}
				.padding(.bottom, 12)
				.padding(.horizontal)
				.padding(.top, 2)
			}
	}
}

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@State private var sample: Samples = .bigOne
	@State private var model = TextModel(text: Samples.bigOne.rawValue)

	var body: some View {
		VStack {
			HStack {
				Picker("Sample", selection: $sample) {
					ForEach(Samples.allCases, id: \.self) { sample in
						Text(title(for: sample))
					}

					Text("Persisted").tag("")
				}
				.pickerStyle(.segmented)
			}
			.padding()

			EditorView(model: model)
		}
		.onChange(of: sample) {
			self.model = TextModel(text: sample.rawValue)
		}
	}

	func title(for sample: Samples) -> String {
		for line in sample.rawValue.components(separatedBy: .newlines) {
			if line.starts(with: "#") {
				return line
			}
		}

		return sample.rawValue.components(separatedBy: .newlines)[0]
	}
}

#Preview {
	ContentView()
		.modelContainer(for: Item.self, inMemory: true)
}
