//  BusOperator.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public enum BusOperator: String, Codable, Sendable, Hashable {
    case sbst = "SBST"
    case smrt = "SMRT"
    case towerTransit = "TTS"
    case goAhead = "GAS"
    case unknown
}
