//  String++.swift
//
//  Copyright © 2024 Aung Ko Min.
//

import Foundation

public extension String {
    func replace(_ target: String, with string: String) -> String {
        replacingOccurrences(of: target, with: string, options: NSString.CompareOptions.literal, range: nil)
    }
}
