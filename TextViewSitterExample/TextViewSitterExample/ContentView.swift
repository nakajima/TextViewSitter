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
