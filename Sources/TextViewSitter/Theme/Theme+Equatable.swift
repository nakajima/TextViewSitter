//
//  File.swift
//  
//
//  Created by Pat Nakajima on 5/25/24.
//

import Foundation

extension Theme: Equatable {
	public static func ==(lhs: Theme, rhs: Theme) -> Bool {
		lhs.fontFamily.name == rhs.fontFamily.name && lhs.fontSize == rhs.fontSize && lhs.colors == rhs.colors
	}
}
