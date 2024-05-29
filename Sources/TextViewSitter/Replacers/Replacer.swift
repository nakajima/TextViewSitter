//
//  Replacer.swift
//
//
//  Created by Pat Nakajima on 5/28/24.
//

import Foundation
import Rearrange

@MainActor protocol Replacer {
	func handler(for trigger: ReplacerTrigger, in textView: TextView, selection: NSRange) -> ReplacerResult?
}
