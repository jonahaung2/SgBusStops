//  Debouncer.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public actor Debouncer {
    private var task: Task<Void, Never>?
    private var hasFiredLeading = false

    public init() {}

    public func submit(
        delay: Duration,
        leading: Bool = true,
        operation: @escaping @Sendable () async -> Void
    ) {
        if leading, !hasFiredLeading {
            hasFiredLeading = true
            Task { await operation() }
        }

        task?.cancel()

        task = Task {
            do {
                try await Task.sleep(for: delay)
                if Task.isCancelled { return }

                await operation()
                hasFiredLeading = false
            } catch {}
        }
    }

    public func cancel() {
        task?.cancel()
        task = nil
        hasFiredLeading = false
    }
}
