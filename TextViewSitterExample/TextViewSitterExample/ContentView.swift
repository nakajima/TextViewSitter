//
//  ContentView.swift
//  TextViewSitterExample
//
//  Created by Pat Nakajima on 5/24/24.
//

import SwiftData
import SwiftUI
import TextViewSitter

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var sample: Samples = .superBasic
    @State private var text = Samples.superBasic.rawValue

    var body: some View {
        VStack {
            Picker("Sample", selection: $sample) {
                ForEach(Samples.allCases, id: \.self) { sample in
                    Text(title(for: sample))
                }
            }
            .pickerStyle(.segmented)
            .padding()

            TreeSitterUI(text: self.$text)
        }
        .onChange(of: sample) {
            self.text = sample.rawValue
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
