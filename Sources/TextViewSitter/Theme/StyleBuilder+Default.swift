//
//  StyleBuilder+Default.swift
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
			theme["markup.strong"] = [.bold]
			theme["markup.italic"] = [.italic]
			theme["text.title"] = [.bold]
			theme["conceal"] = .secondary
			theme["punctuation.special"] = .secondary
			theme["punctuation.delimiter"] = .secondary
			theme["list-item"] = ListItemStyle()
			theme["none"] = .primary

			// Headers
			theme["markup.heading.1"] = [.bold]
			theme["markup.heading.2"] = [.bold]
			theme["markup.heading.3"] = [.bold]
			theme["markup.heading.4"] = [.bold]
			theme["markup.heading.5"] = [.bold]
			theme["markup.heading.6"] = [.bold]

			// Link styles
			theme["markup.link"] = .secondary
			theme["markup.link.label"] = .accentColor
			theme["markup.link.url"] = .accentColor
			theme["link_destination"] = .accentColor
			theme["link_text"] = .accentColor

			// Code
			theme["nospell"] = .primary
			theme["markup.raw.block"] = .secondary
			theme["comment"] = .secondary
			theme["keyword"] = .pink
			theme["method"] = Color.cyan
			theme["parameter"] = .primary
			theme["function.call"] = Color.cyan
			theme["variable.builtin"] = .pink
			theme["type"] = Color.cyan
			theme["string"] = Color.red
			theme["keyword.function"] = .pink
			theme["punctuation.bracket"] = .primary

			theme["property"] = .pink
		}.styles
	}
}
