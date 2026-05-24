//  SettingsScene.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import UI
import Anima
import UIKit
import Client
import Models
import SgMaps
import SwiftUI
import Services
import StoreKit

struct SettingsScene: View {

    @Environment(BusStore.self) private var store
    @AppStorage("nearbyDistance") private var nearbyDistance: Double = 1000
    @AppStorage("show_map_at_bus_stop_arrival") private var showMapAtBusStopArrival = true
    @AppStorage("arrival_refresh_interval") private var arrivalRefreshInterval: Double = 20

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }

    private var hasAPIKey: Bool {
        guard let key = AppSecrets.apiKey() else { return false }
        return !key.isEmpty
    }

    var body: some View {
        Form {
            if let error = store.error {
                Section {
                    ContentUnavailableView {
                        Label(error.title, systemImage: error.imageName)
                    } description: {
                        Text(error.description)
                    } actions: {
                        Button("Try Again") {
                            Task {
                                await store.fetch(forceRefresh: true)
                            }
                        }
                    }
                }
            }

            // MARK: - Data Update & System Settings
            Section {
                Button {
                    Task { await store.fetch(forceRefresh: true) }
                } label: {
                    Label {
                        if store.isLoading {
                            ProgressView().controlSize(.mini)
                        } else {
                            Text("Refresh latest bus data")
                        }
                    } icon: {
                        IconView {
                            Image(systemName: "tray.and.arrow.down.fill")
                        }
                        .foregroundStyle(Color.indigo)
                    }
                }
            } header: {
                Text("Updates")
            } footer: {
                HStack {
                    Text("Version \(appVersion)")
                    Spacer()
                    Text("Build \(buildNumber)")
                }
            }

            Section {
                Label {
                    LabeledContent("API Key") {
                        Text(hasAPIKey ? "Configured" : "API Key Missing")
                    }
                } icon: {
                    IconView {
                        Image(systemName: "key.shield")
                    }
                    .foregroundStyle(Color.green)
                }

                Label {
                    Stepper(
                        "Search Radius: \(nearbyDistance.formatted())m",
                        value: .init(get: { nearbyDistance }, set: { nearbyDistance = $0 }),
                        in: 50 ... 3000,
                        step: 50
                    )
                } icon: {
                    IconView {
                        Image(systemName: "location.fill")
                    }
                    .foregroundStyle(Color.orange)
                }
                Label {
                    Stepper(
                        "Refresh Interval: \(arrivalRefreshInterval.formatted())s",
                        value: .init(get: { arrivalRefreshInterval }, set: { arrivalRefreshInterval = $0 }),
                        in: 20 ... 60,
                        step: 5
                    )
                } icon: {
                    IconView {
                        Image(systemName: "arrow.trianglehead.2.counterclockwise")
                    }
                    .foregroundStyle(Color.brown)
                }
                Label {
                    Toggle("View on Map", isOn: $showMapAtBusStopArrival)
                } icon: {
                    IconView {
                        Image(systemName: "rotate.3d.fill")
                    }
                    .foregroundStyle(Color.purple)
                }
            } header: {
                HStack {
                    Text("Controls")
                    Spacer()
                    Text("")
                        .changeEffect(.rise {
                            Text("-+\(nearbyDistance.formatted())")
                                .font(.caption2.bold())
                                .foregroundStyle(Color.pink.gradient)
                                .shadow(color: .gray, radius: 0.5, y: 0.5)
                        }, value: nearbyDistance)
                }
            }

            Section("App") {
                if let url = URL(string: "https://jonahaung2.github.io/sg-bus-app-privacy/") {
                    Link(destination: url) {
                        Label {
                            Text("Privacy Policy")
                        } icon: {
                            IconView {
                                Image(systemName: "quote.closing")
                            }
                            .foregroundStyle(Color.red)
                        }
                    }
                }
                Label {
                    Button("Rate this App") {
                        requestAppReview()
                    }
                } icon: {
                    IconView {
                        Image(systemName: "star.fill")
                    }
                    .foregroundStyle(Color.blue)
                }
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    Link(destination: url) {
                        Label {
                            Text("Open iOS Settings")
                        } icon: {
                            IconView {
                                Image(systemName: "shield.pattern.checkered")
                            }
                            .foregroundStyle(Color.brown)
                        }
                    }
                }
            }

            Section {} footer: {
                Text(.init(aboutThisApp))
                    .padding(.vertical)
            }.tint(Color.blue)
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .subtitle) {
                Image("header/truck/Bus 1", bundle: .main)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 50)
            }
        }
    }

    private let aboutThisApp = """
    **About This App**

    Developed by [Aung Ko Min](https://github.com/jonahaung), this app helps commuters check real-time bus arrivals quickly and easily — with just one tap, and without ads or unnecessary clutter.

    All transit information comes from publicly available data provided by the Singapore Land Transport Authority (LTA) DataMall. For official updates, please refer to [LTA DataMall](https://datamall.lta.gov.sg/content/datamall/en.html).

    The developer is not responsible for the accuracy, completeness, or availability of the transit data. Use this app as a guide; actual bus arrival times may vary.
    """
    func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
    }
}
