//  BusOperatorBadge.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftUI

extension BusOperator {
    var badge: some View {
        Image(rawValue)
            .resizable()
            .scaledToFit()
    }
}
