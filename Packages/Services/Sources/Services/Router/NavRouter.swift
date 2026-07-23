//  NavRouter.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftUI
import Observation

@MainActor
@Observable
public final class NavRouter: Identifiable, @MainActor Equatable {
    public static func == (lhs: NavRouter, rhs: NavRouter) -> Bool {
        lhs.id == rhs.id
    }

    public let id: TabPath
    public var path: [NavPath] = []
    public var pathBinding: Binding<[NavPath]> {
        .init(get: { self.path }, set: { self.path = $0 })
    }

    public init(id: TabPath) {
        self.id = id
    }

    public func push(_ newValue: NavPath) {
        path.append(newValue)
    }
}
