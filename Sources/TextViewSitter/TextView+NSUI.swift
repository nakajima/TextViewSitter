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

	func withoutScrolling(perform: () -> Void) {
		let oldIsScrollingDisabled = isScrollingDisabled
		isScrollingDisabled = true
		perform()
		isScrollingDisabled = oldIsScrollingDisabled
	}
}
