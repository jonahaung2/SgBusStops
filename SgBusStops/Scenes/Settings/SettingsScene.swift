import Client
import Models
import Services
import SgMaps
import SwiftUI
import UIKit
import UI

struct SettingsScene: View {
	@Environment(\.openURL) private var openURL
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
			Section {
				Stepper {
					Text("\(Int(nearbyDistance))m ")
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
			} header: {
				Text("Nearby distance")
			}

			Section {
				Button {
					Task {
						do {
							try await SwiftDataStore.shared.busStopStore.deleteAll()
						} catch {}
					}
				} label: {
					Label {
						Text("Update to latest data")
					} icon: {
						IconView {
							Image(systemName: "tray.and.arrow.down.fill")
						}
						.foregroundStyle(RandomShapeStyle.style(for: "tray.and.arrow.down.fill"))
					}
				}
				Button {
					guard let url = URL(string: UIApplication.openSettingsURLString) else {
						return
					}
					openURL(url)
				} label: {
					Label {
						Text("Open System Settings")
					} icon: {
						IconView {
							Image(systemName: "shield.pattern.checkered")
						}
						.foregroundStyle(RandomShapeStyle.style(for: "shield.pattern.checkered"))
					}
				}
			}

			Section {
				Label {
					LabeledContent("API Key") {
						Text(hasAPIKey ? "Configured" : "Missing")
							.foregroundStyle(hasAPIKey ? .green : .red)
					}
				} icon: {
					IconView {
						Image(systemName: "key.shield")
					}
					.foregroundStyle(RandomShapeStyle.style(for: "key.shield"))
				}
				if !hasAPIKey {
					Text("Set PUBLIC_API_KEY in app configuration to enable live data.")
						.font(.footnote)
						.foregroundStyle(.secondary)
				}
			} header: {
				HStack {
					Text("Version \(appVersion)")
					Text("Build \(buildNumber)")
				}
			} footer: {
				Text(.init(aboutThisApp))
			}
		}
	}

	private let aboutThisApp = """
**About This App**
This app was developed by [Aung Ko Min](https://github.com/jonahaung) to help commuters quickly check real-time bus arrivals in one click, with no ads or clutter.
All transit data is sourced from publicly available APIs provided by the Singapore Land Transport Authority (LTA) DataMall. For official information, see [LTA DataMall](https://datamall.lta.gov.sg/content/datamall/en.html)
The developer is not responsible for the accuracy, completeness, or availability of transit data. Use the app as a guide — actual bus arrivals may vary.
"""
}
