//  Toast.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI

public struct Toast {
    public struct Style {
        public let alignment: Alignment
        public let edge: Edge

        public init(alignment: Alignment = .top, edge: Edge = .top) {
            self.alignment = alignment
            self.edge = edge
        }
    }

    public let node: AnyView
    public let style: Style
    public let duration: TimeInterval
    public let allowsBackgroundTap: Bool
    public let action: (@MainActor () -> Void)?

    public init(
        node: AnyView,
        style: Style = .init(),
        duration: TimeInterval = 2.5,
        allowsBackgroundTap: Bool = true,
        action: (@MainActor () -> Void)? = nil
    ) {
        self.node = node
        self.style = style
        self.duration = duration
        self.allowsBackgroundTap = allowsBackgroundTap
        self.action = action
    }

    public init(
        message: String,
        style: Style = .init(),
        duration: TimeInterval = 2.5,
        allowsBackgroundTap: Bool = true,
        action: (@MainActor () -> Void)? = nil
    ) {
        self.init(
            node: AnyView(
                Text(message)
                    .multilineTextAlignment(.center)
            ),
            style: style,
            duration: duration,
            allowsBackgroundTap: allowsBackgroundTap,
            action: action
        )
    }
}
