//
//  TextView+TextInterface.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation
import TextFormation
import TextStory

extension TextView: TextStoring {
	public var length: Int {
		nsuiTextStorage!.length
	}

	public func substring(from range: NSRange) -> String? {
		nsuiTextStorage!.substring(from: range)
	}

	public func applyMutation(_ mutation: TextMutation) {
		nsuiTextStorage!.applyMutation(mutation)
	}
}
