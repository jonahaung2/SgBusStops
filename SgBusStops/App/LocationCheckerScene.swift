//
//  LocationCheckerScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 1/3/26.
//

import CoreLocation
import Services
import SwiftUI
import UI

struct LocationCheckerScene: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var controller = LocationAuthorizationController()

    var body: some View {
        Group {
            switch controller.phase {
            case .authorized:
                MainTabView()
            case .checkingAuthorization, .requestingHardware:
                VStack(spacing: 16) {
                    ProgressView()
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
                    Button(controller.buttonTitle) {
                        if controller.shouldOpenSettings {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                openURL(url)
                            }
                        } else {
                            controller.requestPermission()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonSizing(.fitted)
                }
            }
        }
        .task {
            controller.refreshAuthorization()
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                controller.refreshAuthorization()
            }
        }
    }
}

@MainActor
@Observable
final class LocationAuthorizationController: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private(set) var phase: LocationRequestPhase = .checkingAuthorization
    private(set) var authorizationStatus: CLAuthorizationStatus

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        refreshAuthorization()
    }

    var shouldOpenSettings: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    var buttonTitle: String {
        shouldOpenSettings ? "Open Settings" : "Enable Location"
    }

    func requestPermission() {
        authorizationStatus = manager.authorizationStatus
        switch authorizationStatus {
        case .notDetermined:
            phase = .requestingHardware
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            phase = .authorized
        case .denied:
            phase = .failed(.permissionDenied)
        case .restricted:
            phase = .failed(.restricted)
        @unknown default:
            phase = .failed(.unknown)
        }
    }

    func refreshAuthorization() {
        authorizationStatus = manager.authorizationStatus
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            phase = .authorized
        case .notDetermined:
            phase = .authorizationRequired
        case .denied:
            phase = .failed(.permissionDenied)
        case .restricted:
            phase = .failed(.restricted)
        @unknown default:
            phase = .failed(.unknown)
        }
    }

    func locationManagerDidChangeAuthorization(_: CLLocationManager) {
        refreshAuthorization()
    }
}
