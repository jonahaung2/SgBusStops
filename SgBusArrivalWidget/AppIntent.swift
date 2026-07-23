//  AppIntent.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import AppIntents

struct EndBusArrivalActivityIntent: AppIntent {
    static let title: LocalizedStringResource = "End Bus Arrival Activity"
    static let description = IntentDescription("Stops the active bus arrival Live Activity.")

    func perform() async throws -> some IntentResult {
        await LiveActivityManager.endAll()
        return .result()
    }
}
