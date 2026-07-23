//  Bus.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public struct Bus: Sendable, Hashable, Identifiable {
    public var id: String { busNumber + direction.rawValue.description }
    public let busNumber: BusNumber
    public let direction: BusDirection
    public let busOperator: BusOperator

    public init(_ busNumber: BusNumber, _ direction: BusDirection, busOperator: BusOperator) {
        self.busNumber = busNumber
        self.direction = direction
        self.busOperator = busOperator
    }
}
