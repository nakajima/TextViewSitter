//
//  File.swift
//  
//
//  Created by Pat Nakajima on 5/25/24.
//

import Foundation
import NSUI
import SwiftUI

extension StyleBuilder {
	static var `default`: [String: any Style] {
		StyleBuilder { theme in
			theme["text.reference"] = .accentColor
			theme["text.code"] = Color.cyan
			theme["text.strong"] = [.bold]
			theme["text.title"] = [.bold]
			theme["text.emphasis"] = [.italic]
			theme["punctuation.special"] = .secondary
			theme["punctuation.delimiter"] = .secondary
			theme["list-item"] = ListItemStyle()

			// Code
			theme["comment"] = .secondary
			theme["keyword"] = .pink
			theme["method"] = .indigo
			theme["parameter"] = .primary
			theme["text.uri"] = .secondary
			theme["function.call"] = Color.cyan
			theme["variable.builtin"] = .pink
			theme["type"] = Color.cyan
			theme["string"] = Color.red
			theme["keyword.function"] = .pink
			theme["punctuation.bracket"] = .primary
		}.styles
	}
}
