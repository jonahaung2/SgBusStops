//
//  PreciseRepeater.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 29/3/26.
//


//
//  PreciseRepeater.swift
//  Services
//
//  Created by Aung Ko Min on 18/3/26.
//

import Foundation

public actor PreciseRepeater {
    // MARK: - State

    private var task: Task<Void, Never>?
    private var isPaused = false
    private var nextFire: ContinuousClock.Instant?
    private var isRunning = false

    // MARK: - Public API

    public init() {}

    public func start(
        interval: Duration,
        tolerance: Duration? = nil,
        immediate: Bool = false,
        preventOverlap: Bool = true,
        operation: @escaping @Sendable () async -> Void,
    ) {
        guard task == nil else { return }

        task = Task {
            let clock = ContinuousClock()
            var next = clock.now

            if immediate {
                await operation()
            }

            while !Task.isCancelled {
                if isPaused {
                    try? await Task.sleep(for: .milliseconds(200))
                    continue
                }

                next += interval
                nextFire = next

                do {
                    try await clock.sleep(until: next, tolerance: tolerance)
                } catch {
                    break
                }

                if Task.isCancelled { break }
                if isPaused { continue }

                if preventOverlap {
                    if isRunning { continue }
                    isRunning = true
                }

                await operation()

                if preventOverlap {
                    isRunning = false
                }
            }
        }
    }

    public func stop() {
        task?.cancel()
        task = nil
        nextFire = nil
        isPaused = false
    }

    public func pause() {
        isPaused = true
    }

    public func resume() {
        isPaused = false
    }

    deinit {
        task?.cancel()
    }
}
