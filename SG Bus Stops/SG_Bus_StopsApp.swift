//
//  SG_Bus_StopsApp.swift
//  SG Bus Stops
//
//  Created by Aung Ko Min on 19/2/26.
//

import SwiftUI

@main
struct SG_Bus_StopsApp: App {
    init() {
        AppSecrets.bootstrapAPIKey()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
