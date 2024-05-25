//
//  Highlight.swift
//
//
//  Created by Pat Nakajima on 5/24/24.
//

import Foundation
import NSUI

public struct Highlight {
	var name: String
	var range: NSRange
	var style: [NSAttributedString.Key: Any]
}
