//  LiveActivityModel.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

struct LiveActivityModel: Sendable, Hashable, Identifiable {
    var id: String { busNumber + stopCode }
    let busNumber: String
    let stopCode: String
    let stopName: String
    var date: Date
}
