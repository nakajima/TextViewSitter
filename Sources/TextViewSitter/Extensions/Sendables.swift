//
//  Sendables.swift
//
//
//  Created by Pat Nakajima on 5/27/24.
//

import Foundation
import NSUI
import OSLog

#if swift(>=6.0)
	#warning("Reevaluate whether this decoration is necessary.")
#endif
extension Logger: @unchecked Sendable {}

#if swift(>=6.0)
	#warning("Reevaluate whether this decoration is necessary.")
#endif
extension NSUIFont: @unchecked Sendable {}

#if swift(>=6.0)
	#warning("Reevaluate whether this decoration is necessary.")
#endif
extension NSParagraphStyle: @unchecked Sendable {}
