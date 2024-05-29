//
//  TextView+NSUI.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation

extension TextView {
	var value: String {
		#if os(macOS)
			string
		#else
			text
		#endif
	}

	func preserveScrollPositionAndSelection(perform: () -> Void) {
		let currentSelection = selectedRange
		isScrollingDisabled = true
		perform()
		DispatchQueue.main.async {
			self.setSelectedRange(currentSelection)
			self.isScrollingDisabled = false
		}
	}

	func withoutScrolling(perform: () -> Void) {
		let oldIsScrollingDisabled = isScrollingDisabled
		isScrollingDisabled = true
		perform()
		isScrollingDisabled = oldIsScrollingDisabled
	}
}
