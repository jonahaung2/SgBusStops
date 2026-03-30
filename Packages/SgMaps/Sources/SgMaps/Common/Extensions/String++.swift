//
//  String++.swift
//
//
//  Created by Aung Ko Min on 5/8/24.
//

import Foundation

public extension String {
    func replace(_ target: String, with string: String) -> String {
        replacingOccurrences(of: target, with: string, options: NSString.CompareOptions.literal, range: nil)
    }
}
