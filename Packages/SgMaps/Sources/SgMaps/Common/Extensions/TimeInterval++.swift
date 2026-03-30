//
//  TimeInterval++.swift
//  SgMaps
//
//  Created by Aung Ko Min on 25/9/24.
//

import Foundation

public extension TimeInterval {
    var minutes: Int {
        Int(rounded() / 60)
    }

    var seconds: Int {
        Int(rounded())
    }

    var milliseconds: Int {
        Int(self * 1000)
    }
}
