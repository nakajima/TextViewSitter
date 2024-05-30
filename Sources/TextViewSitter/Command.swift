//
//  Command.swift
//
//
//  Created by Pat Nakajima on 5/28/24.
//

import Foundation
import Rearrange

@MainActor protocol Command {
	func handler(for trigger: CommandTrigger, in textView: TextView, selection: NSRange) -> CommandResult?
}
