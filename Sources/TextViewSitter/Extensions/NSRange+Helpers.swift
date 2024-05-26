//
//  NSRange+Helpers.swift
//
//
//  Created by Pat Nakajima on 5/25/24.
//

import Foundation
import NSUI

extension NSRange {
	init(textStorage: NSTextStorage) {
		self.init(location: 0, length: textStorage.length)
	}
}
