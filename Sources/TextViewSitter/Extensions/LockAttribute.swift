//
//  LockAttribute.swift
//
//
//  Created by Pat Nakajima on 5/27/24.
//

import Foundation
import os

@propertyWrapper struct LockAttribute<T: Sendable>: Sendable {
	let lock: OSAllocatedUnfairLock<T>

	var wrappedValue: T {
		get {
			return lock.withLock { state in state }
		}
		set {
			lock.withLock { state in state = newValue }
		}
	}

	init(wrappedValue: T) {
		self.lock = OSAllocatedUnfairLock(initialState: wrappedValue)
	}
}
