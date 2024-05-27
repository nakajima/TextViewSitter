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
class TextModel: Equatable, TextViewSitterTextModel {
	static func == (lhs: TextModel, rhs: TextModel) -> Bool {
		return lhs.id == rhs.id
	}

	var id: String
	var text: String

	init(id: String, text: String) {
		self.id = id
		self.text = text
	}
}

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@State private var sample: Samples = .basic
	@State private var model = TextModel(id: Samples.basic.id, text: Samples.basic.rawValue)

	var body: some View {
		NavigationStack {
			EditorView(model: model)
				.onChange(of: sample) {
					self.model = TextModel(id: sample.id, text: sample.rawValue)
				}
				.safeAreaInset(edge: .top, spacing: 0) {
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
					.background(.clear)
				}
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
