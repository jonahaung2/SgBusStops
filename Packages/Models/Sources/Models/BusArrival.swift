//  BusArrival.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public struct BusArrival: Codable, Hashable, Sendable {
    public let serviceNo: String
    public let operatorCode: BusOperator
    public let nextBus: Arrival?
    public let nextBus2: Arrival?
    public let nextBus3: Arrival?

    enum CodingKeys: String, CodingKey {
        case serviceNo = "ServiceNo"
        case operatorCode = "Operator"
        case nextBus = "NextBus"
        case nextBus2 = "NextBus2"
        case nextBus3 = "NextBus3"
    }
}

extension BusArrival: Identifiable {
    public var id: String {
        serviceNo
    }
}
