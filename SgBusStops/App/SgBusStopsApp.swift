//  SgBusStopsApp.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Client
import SwiftUI
import Services

@main
struct SgBusStopsApp: App {
    init() {
        AppSecrets.bootstrapAPIKey()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
