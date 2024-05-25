//
//  File.swift
//  
//
//  Created by Pat Nakajima on 5/25/24.
//

import SwiftTreeSitter

extension String {
	public var predicateTextProvider: Predicate.TextProvider {
		return { (nsRange, _) in
			guard let range = Range<String.Index>(nsRange, in: self) else {
				return nil
			}

			return String(self[range])
		}
	}
}
