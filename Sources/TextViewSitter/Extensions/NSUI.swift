//
//  NSUI.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation
import NSUI

#if os(macOS)
	public typealias NSUITextViewDelegate = NSTextViewDelegate
	public typealias NSUIModifierFlags = NSEvent.ModifierFlags
#else
	public typealias NSUITextViewDelegate = UITextViewDelegate
	public typealias NSUIModifierFlags = UIKeyModifierFlags

	extension NSUIModifierFlags {
		static let option: NSUIModifierFlags = .alternate
	}
#endif
