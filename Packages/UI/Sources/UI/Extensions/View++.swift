//  View++.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI

public extension View {
    func colorfulForeground() -> some View {
        foregroundStyle(
            AngularGradient(
                colors: [.indigo, Color(uiColor: .label), .red],
                center: .center
            )
        )
    }
}
