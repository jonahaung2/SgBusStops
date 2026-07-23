//  BusDirection.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public enum BusDirection: Int, Codable, Sendable, Hashable, CaseIterable {
    case none
    case inbound = 1
    case outbound = 2
}
