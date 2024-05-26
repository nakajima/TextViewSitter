//
//  CaretState.swift
//
//
//  Created by Pat Nakajima on 5/26/24.
//

import Foundation

public struct CaretState {
	public var position: Int = 0
	public var highlights: [Highlight] = []

	public init() {}

	init(position: Int, highlights: [Highlight]) {
		self.position = position
		self.highlights = highlights
	}
}
