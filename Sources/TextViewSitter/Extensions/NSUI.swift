//
//  NSUI.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation
import NSUI

#if os(macOS)
	typealias NSUITextViewDelegate = NSTextViewDelegate
#else
	typealias NSUITextViewDelegate = UITextViewDelegate
#endif
