//
//  File.swift
//  
//
//  Created by Pat Nakajima on 5/27/24.
//

import Foundation
import OSLog



#if swift(>=6.0)
	#warning("Reevaluate whether this decoration is necessary.")
#endif
extension Logger: @unchecked Sendable {}
