import Client
import Models
import Services
import SgMaps
import SwiftUI
import UIKit

struct SettingsScene: View {
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }

    private var hasAPIKey: Bool {
        guard let key = AppSecrets.apiKey() else {
            return false
        }
        return !key.isEmpty
    }

    @AppStorage("nearbyDistance") private var nearbyDistance: Double = 1000

    var body: some View {
        Form {
            Section("Application") {
                LabeledContent("Version", value: appVersion)
                LabeledContent("Build", value: buildNumber)
            }
            Section("Connectivity") {
                LabeledContent("API Key") {
                    Text(hasAPIKey ? "Configured" : "Missing")
                        .foregroundStyle(hasAPIKey ? .green : .red)
                }
                if !hasAPIKey {
                    Text("Set PUBLIC_API_KEY in app configuration to enable live data.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Section("Maps") {
                NavigationLink {
                    SgAreaMapView { area in
                        print(area)
                    }

                } label: {
                    Text("Area Map")
                }
                NavigationLink {
                    SgMrtMapView { mrt in
                        print(mrt)
                    }

                } label: {
                    Text("MRT Map")
                }
            }
            Section("Data") {
                Stepper {
                    Text("Nearby distance").badge("\(Int(nearbyDistance))m ")
                } onIncrement: {
                    if nearbyDistance < 2000 {
                        nearbyDistance += 50
                    }
                } onDecrement: {
                    if nearbyDistance > 50 {
                        nearbyDistance -= 50
                    }
                } onEditingChanged: { changed in
                    print(changed)
                }

                Button("Delete Cache", role: .destructive) {
                    Task {
                        do {
                            try await SwiftDataStore.shared.busStopStore.deleteAll()
                        } catch {}
                    }
                }
            }
            Section("Permissions") {
                Button("Open System Settings") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}
