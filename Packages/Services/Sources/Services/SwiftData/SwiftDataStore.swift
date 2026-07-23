//  SwiftDataStore.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftData

public actor SwiftDataStore {
    public static let shared: SwiftDataStore = .init()
    public static let persistentStoreName = "SgBusStopsStore1"

    public nonisolated let appContainer: AppContainer
    public var store: StoreDataActor

    public init() {
        let appContainer = AppContainer(migrationPlan: nil, id: Self.persistentStoreName)
        let modelContainer = appContainer.modelContainer
        let context = ModelContext(modelContainer)
        context.autosaveEnabled = false
        let modelExecutor = DefaultSerialModelExecutor(modelContext: context)
        self.appContainer = appContainer
        store = .init(
            modelContainer: modelContainer,
            modelExecutor: modelExecutor
        )
    }
}
