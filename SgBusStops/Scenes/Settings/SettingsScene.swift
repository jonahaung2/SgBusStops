//
//  SettingsScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 18/3/26.
//

import Client
import Models
import Services
import SgMaps
import SwiftUI
import UIKit
import UI
import StoreKit

struct SettingsScene: View {

	@Environment(\.openURL) private var openURL
	@Environment(BusStore.self) private var store

	@AppStorage("nearbyDistance") private var nearbyDistance: Double = 1000

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
								await store.refreshData()
							}
						}
					}
				}
			}

			// MARK: - Data Update & System Settings
			Section {
				Button {
					Task { await store.refreshData() }
				} label: {
					Label {
						if store.isLoading {
							ProgressView().controlSize(.mini)
						} else {
							Text("Refresh Data")
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

			Section("Controls") {
				Label {
					LabeledContent("API Key") {
						Text(hasAPIKey ? "API Key Set" : "API Key Missing")
					}
				} icon: {
					IconView {
						Image(systemName: "key.shield")
					}
					.foregroundStyle(Color.green)
				}

				Label {
					Stepper(
						"Nearby Radius: \(nearbyDistance.formatted()) m",
						value: .init(get: { nearbyDistance }, set: { nearbyDistance = $0 }),
						in: 50...3000,
						step: 50
					)
				} icon: {
					IconView {
						Image(systemName: "location.fill")
					}
					.foregroundStyle(Color.orange)
				}
			}

			Section("App") {
				Label {
					Button {
						guard let url = URL(string: "https://jonahaung2.github.io/sg-bus-app-privacy/") else { return }
						openURL(url)
					} label: {
						Text("Privacy Policy")
					}
				} icon: {
					IconView {
						Image(systemName: "quote.closing")
					}
					.foregroundStyle(Color.red)
				}
				Label {
					Button("Rate This App") {
						requestAppReview()
					}
				} icon: {
					IconView {
						Image(systemName: "star.fill")
					}
					.foregroundStyle(Color.blue)
				}

				Button {
					guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
					openURL(url)
				} label: {
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

			// MARK: - About
			Section {} footer: {
				Text(.init(aboutThisApp))
			}
		}
	}

	// MARK: - About This App
	private let aboutThisApp = """
 **About This App**
 
 Developed by [Aung Ko Min](https://github.com/jonahaung), this app helps commuters check real-time bus arrivals quickly and easily — with just one tap, and without ads or unnecessary clutter.
 
 All transit information comes from publicly available data provided by the Singapore Land Transport Authority (LTA) DataMall. For official updates, please refer to [LTA DataMall](https://datamall.lta.gov.sg/content/datamall/en.html).
 
 The developer is not responsible for the accuracy, completeness, or availability of the transit data. Use this app as a guide; actual bus arrival times may vary.
 """
	private func viewModelTask() async {
		await store.refreshData()
	}

	func requestAppReview() {
		if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
			AppStore.requestReview(in: scene)
		}
	}
}
