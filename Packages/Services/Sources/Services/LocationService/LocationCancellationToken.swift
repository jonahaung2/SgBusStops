//  LocationCancellationToken.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation
import CoreLocation

// MARK: - Cancellation Token

public final class LocationCancellationToken: @unchecked Sendable {
    private let lock: NSLock = .init()
    private var _cancelled = false

    public init() {}

    public func cancel() {
        lock.lock()
        _cancelled = true
        lock.unlock()
    }

    public var isCancelled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _cancelled
    }
}
