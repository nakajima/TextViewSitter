//
//  TextViewFilters.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation
import TextFormation

@MainActor enum TextViewFilters {
	static let codeMutations = TextViewFilterApplier(
		filters: [
			StandardOpenPairFilter(open: "{", close: "}"),
			StandardOpenPairFilter(open: "[", close: "]"),
			StandardOpenPairFilter(same: #"#"#),
			StandardOpenPairFilter(same: "'"),
			NewlineProcessingFilter(),
		],
		providers: WhitespaceProviders(
			leadingWhitespace: TextualIndenter().substitionProvider(
				indentationUnit: "\t",
				width: 1
			),
			trailingWhitespace: { _, _ in "" }
		)
	)

	static let markdownMutations = TextViewFilterApplier(
		filters: [
			StandardOpenPairFilter(same: #"#"#),
			StandardOpenPairFilter(same: "'"),
		],
		providers: .none
	)
}
