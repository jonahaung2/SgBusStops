//  PreciseRepeatingTaskModifier.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI

public struct PreciseRepeatingTaskModifier: ViewModifier {
    let interval: Duration
    let tolerance: Duration?
    let immediate: Bool
    let preventOverlap: Bool
    let action: @Sendable () async -> Void

    @State private var repeater: PreciseRepeater = .init()

    public func body(content: Content) -> some View {
        content
            .task {
                await repeater.start(
                    interval: interval,
                    tolerance: tolerance,
                    immediate: immediate,
                    preventOverlap: preventOverlap,
                    operation: action
                )
            }
            .onDisappear {
                Task { await repeater.stop() }
            }
            .onAppLifecycle(
                active: {
                    Task { await repeater.resume() }
                },
                background: {
                    Task { await repeater.pause() }
                }
            )
    }
}

public extension View {
    func repeatingTask(
        every interval: Duration,
        tolerance: Duration? = .seconds(1),
        immediate: Bool = true,
        preventOverlap: Bool = true,
        _ action: @escaping @Sendable () async -> Void
    ) -> some View {
        modifier(
            PreciseRepeatingTaskModifier(
                interval: interval,
                tolerance: tolerance,
                immediate: immediate,
                preventOverlap: preventOverlap,
                action: action
            )
        )
    }
}
