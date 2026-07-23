//
//  InvisibleModifier.swift
//  SGPopTip
//
//  Created by Aung Ko Min on 23/5/26.
//

import SwiftUI

public enum ArrowDirection: Sendable, Hashable {
    case top(offset: CGFloat)
    case topLeading(offset: CGFloat)
    case topTrailing(offset: CGFloat)
    case bottom(offset: CGFloat)
    case bottomLeading(offset: CGFloat)
    case bottomTrailing(offset: CGFloat)
}

public extension ArrowDirection {
    static var top: ArrowDirection { .top(offset: .infinity) }
    static var bottom: ArrowDirection { .bottom(offset: .infinity) }

    static var topLeading: ArrowDirection { .topLeading(offset: 0) }
    static var topTrailing: ArrowDirection { .topTrailing(offset: .greatestFiniteMagnitude) }
    static var bottomLeading: ArrowDirection { .bottomLeading(offset: 0) }
    static var bottomTrailing: ArrowDirection { .bottomTrailing(offset: .greatestFiniteMagnitude) }
}
