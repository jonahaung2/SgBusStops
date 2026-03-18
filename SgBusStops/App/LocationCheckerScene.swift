//
//  LocationCheckerScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 1/3/26.
//

import Services
import SwiftUI
import UI

struct LocationCheckerScene: View {

    @Environment(\.openURL) private var openURL
    @State private var controller = LocationAuthorizationController()

    var body: some View {
        Group {
            switch controller.phase {
            case .authorized:
                BusStopDownloadCheckerScene()
            case .checkingAuthorization, .requestingHardware:
                VStack(spacing: 16) {
					LoadingIndicator(24)
                    Text("Checking Location Permission")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            default:
                ContentUnavailableView {
                    Label("Location Access Needed", systemImage: "location.slash")
                } description: {
                    Text("Location access is needed to display bus stops and routes.")
                } actions: {
                    Button {
                        if controller.shouldOpenSettings {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                openURL(url)
                            }
                        } else {
                            controller.requestPermission()
                        }
                    } label: {
                        Text(controller.buttonTitle)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonSizing(.flexible)
                }
            }
        }
        .task {
            controller.refreshAuthorization()
        }
    }
}
