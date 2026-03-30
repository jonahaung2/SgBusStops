//
//  LocationCheckerContentUnavailableView.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 1/3/26.
//

import Services
import SwiftUI
import UI

struct LocationCheckerContentUnavailableView: View {

	@Environment(\.openURL) private var openURL
	@State private var controller = LocationAuthorizationController()

	private var title: String {
		controller.shouldOpenSettings ? "Location Access Needed" : "Nearby Bus Stops"
	}

	private var message: String {
		controller.shouldOpenSettings
		? "Location access is turned off. You can enable it in Settings to view nearby bus stops and real-time transit information."
		: "Allow location access to view nearby bus stops and real-time transit information."
	}

	var body: some View {
		ContentUnavailableView {
			Label(title, systemImage: "location.fill")
		} description: {
			Text(message)
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
