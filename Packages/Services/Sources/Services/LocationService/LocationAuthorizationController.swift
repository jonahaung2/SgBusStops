//  LocationAuthorizationController.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI
import CoreLocation

@Observable
public final class LocationAuthorizationController: NSObject, CLLocationManagerDelegate {
    private let manager: CLLocationManager = .init()
    public private(set) var phase: LocationRequestPhase = .checkingAuthorization
    public private(set) var authorizationStatus: CLAuthorizationStatus

    override public init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        refreshAuthorization()
    }

    public var shouldOpenSettings: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    public var buttonTitle: String {
        shouldOpenSettings ? "Open Settings" : "Continue"
    }

    public func skipPermission() {
        phase = .authorized
    }

    public func requestPermission() {
        authorizationStatus = manager.authorizationStatus
        switch authorizationStatus {
        case .notDetermined:
            phase = .requestingHardware
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways,
             .authorizedWhenInUse:
            phase = .authorized
        case .denied:
            phase = .failed(.permissionDenied)
        case .restricted:
            phase = .failed(.restricted)
        @unknown default:
            phase = .failed(.unknown)
        }
    }

    public func refreshAuthorization() {
        authorizationStatus = manager.authorizationStatus
        phase = switch authorizationStatus {
        case .authorizedAlways,
             .authorizedWhenInUse:
            .authorized
        case .notDetermined:
            .authorizationRequired
        case .denied:
            .failed(.permissionDenied)
        case .restricted:
            .failed(.restricted)
        @unknown default:
            .failed(.unknown)
        }
    }

    public func locationManagerDidChangeAuthorization(_: CLLocationManager) {
        refreshAuthorization()
    }
}
