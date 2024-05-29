//
//  RateLimiting.swift
//
//
//  Created by Pat Nakajima on 5/29/24.
//

import Foundation

@MainActor final class Throttler: @unchecked Sendable {
	typealias Job = @MainActor @Sendable () -> Void

	@LockAttribute var task: Task<Void, Never>?
	@LockAttribute var jobs: [Job] = []

	// How many jobs can we have in the queue before dropping
	let limit: Int

	init(limit: Int = 0) {
		self.limit = limit
	}

	func throttle(action: @escaping Job) {
		if jobs.count <= limit {
			jobs.insert(action, at: 0)
		}

		if task == nil {
			task = Task { @MainActor in
				while let job = jobs.popLast() {
					job()

					do {
						try await Task.sleep(for: .seconds(0.2))
					} catch {
						self.task = nil
					}
				}

				self.task = nil
			}
		}
	}
}

class Debouncer {
	@LockAttribute var task: Task<Void, Never>? = nil

	func debounce(action: @MainActor @Sendable @escaping () -> Void) {
		task?.cancel()
		task = Task { @MainActor in
			do {
				try await Task.sleep(for: .seconds(0.2))
			} catch {
				return
			}

			if Task.isCancelled {
				return
			}

			action()
		}
	}
}
