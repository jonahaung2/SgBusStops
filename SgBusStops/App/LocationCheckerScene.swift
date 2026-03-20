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
					ProgressView().controlSize(.mini)
                    Text("Checking Location Permission")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            default:
                ContentUnavailableView {
                    Label("Enable Location Access", systemImage: "location.slash")
                } description: {
					Text("Allow location access to see nearby bus stops and real-time routes around you.")
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
