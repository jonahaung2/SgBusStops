//  StoreDataActor.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftData
import Foundation
import CoreLocation

public actor StoreDataActor: ModelActor {

    public let modelExecutor: any ModelExecutor
    public let modelContainer: ModelContainer

    var context: ModelContext {
        modelExecutor.modelContext
    }

    private var saveTask: Task<Void, Never>?

    public init(
        modelContainer: ModelContainer,
        modelExecutor: ModelExecutor
    ) {
        self.modelContainer = modelContainer
        self.modelExecutor = modelExecutor
    }
}

public extension StoreDataActor {
    func save() throws {
        saveTask?.cancel()
        saveTask = nil
        try context.save()
    }

    func saveDebounced(after delay: Duration = .seconds(1)) {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else {
                return
            }
            try? context.save()
            saveTask = nil
        }
    }
}
