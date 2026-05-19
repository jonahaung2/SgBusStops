//
//  SgBusStopsApp.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Client
import Services
import SwiftUI

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
