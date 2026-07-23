//  Bus+Stops.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import Foundation

public extension Bus {
    func routes() async throws -> [BusRoutingInfo] {
        try await SwiftDataStore.shared.store.routes(for: self)
    }
}
