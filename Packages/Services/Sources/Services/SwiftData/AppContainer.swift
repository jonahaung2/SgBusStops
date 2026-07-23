//  AppContainer.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftData
import Foundation

public enum AppSchemaV1: VersionedSchema {
    public static let versionIdentifier: Schema.Version = .init(1, 0, 0)
    public static var models: [any PersistentModel.Type] {
        [BusStopModel.self, FavouriteArrivalModel.self, BusRoutingInfoModel.self]
    }
}

public enum AppSchemaMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] { [AppSchemaV1.self] }
    public static var stages: [MigrationStage] { [] }
}

public final class AppContainer: Sendable {
    public let modelContainer: ModelContainer

    public init(migrationPlan: (any SchemaMigrationPlan.Type)? = nil, id: String?) {
        let schema = Schema(
            AppSchemaV1.models
        )
        do {
            try Self.createStoreDirectory()
        } catch {
            fatalError(error.localizedDescription)
        }
        let configuration = ModelConfiguration(
            id,
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .identifier(AppInfo.groupIdentifier)
            // cloudKitDatabase: .private(AppInformation.iCloudID)
        )
        do {
            let modelContainer = try ModelContainer(
                for: schema,
                migrationPlan: migrationPlan ?? AppSchemaMigrationPlan.self,
                configurations: configuration
            )
            self.modelContainer = modelContainer
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    private static func createStoreDirectory() throws {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppInfo.groupIdentifier
        ) else {
            throw CocoaError(.fileNoSuchFile)
        }
        let directoryURL = containerURL
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
    }
}
