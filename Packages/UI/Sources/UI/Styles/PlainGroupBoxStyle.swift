//  PlainGroupBoxStyle.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI

public struct PlainGroupBoxStyle: GroupBoxStyle {
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            configuration.label
            configuration.content
        }
    }

    public init() {}
}

public struct CardGroupBoxStyle: GroupBoxStyle {
    let padding: CGFloat
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            configuration.label
            configuration.content
        }
        .padding(padding)
    }

    public init(padding: CGFloat = 4) {
        self.padding = padding
    }
}
