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
                    Label("Enable Location Access", systemImage: "location.fill.viewfinder")
                } description: {
					Text("Location access is required to display nearby bus stops and real-time transit information.")
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
						Text(controller.buttonTitle).padding(.horizontal)
                    }
					.buttonStyle(.bordered)
                    .buttonSizing(.flexible)
                }
            }
        }
        .task {
            controller.refreshAuthorization()
        }
    }
}
