//  Router.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation
import Observation

@MainActor
@Observable public final class Router {
    public var currentTab: TabPath {
        didSet {
            defaults.set(currentTab.rawValue, forKey: Self.currentTabKey)
        }
    }

    public let navRouters: [NavRouter]

    private let defaults: UserDefaults
    private static let currentTabKey = "router.currentTab"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        navRouters = TabPath.allCases.map(NavRouter.init(id:))
        currentTab =
            defaults.string(forKey: Self.currentTabKey)
            .flatMap(TabPath.init(rawValue:))
            ?? .nearBy
    }
}
