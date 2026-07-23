//  Stop+Busses.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftData
import Foundation

public extension Stop {
    func busses() async throws -> [Bus] {
        try await SwiftDataStore.shared.store.busses(busStopCode: busStopCode)
    }
}
