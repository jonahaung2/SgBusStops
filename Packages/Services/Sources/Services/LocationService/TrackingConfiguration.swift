//  TrackingConfiguration.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import CoreLocation

public struct TrackingConfiguration: Sendable, Equatable {
    public let accuracy: CLLocationAccuracy
    public let distanceFilter: CLLocationDistance
    public let activityType: CLActivityType
    public let allowsBackgroundUpdates: Bool
    public let pausesAutomatically: Bool
    public let showsBackgroundIndicator: Bool

    public init(
        accuracy: CLLocationAccuracy,
        distanceFilter: CLLocationDistance,
        activityType: CLActivityType,
        allowsBackgroundUpdates: Bool,
        pausesAutomatically: Bool,
        showsBackgroundIndicator: Bool
    ) {
        self.accuracy = accuracy
        self.distanceFilter = distanceFilter
        self.activityType = activityType
        self.allowsBackgroundUpdates = allowsBackgroundUpdates
        self.pausesAutomatically = pausesAutomatically
        self.showsBackgroundIndicator = showsBackgroundIndicator
    }
}

public extension TrackingConfiguration {
    static let proximity: TrackingConfiguration = .init(
        accuracy: kCLLocationAccuracyNearestTenMeters,
        distanceFilter: 10,
        activityType: .otherNavigation,
        allowsBackgroundUpdates: false,
        pausesAutomatically: true,
        showsBackgroundIndicator: false
    )

    static let backgroundHybrid: TrackingConfiguration = .init(
        accuracy: kCLLocationAccuracyHundredMeters,
        distanceFilter: 50,
        activityType: .other,
        allowsBackgroundUpdates: true,
        pausesAutomatically: true,
        showsBackgroundIndicator: false
    )

    static let navigation: TrackingConfiguration = .init(
        accuracy: kCLLocationAccuracyBestForNavigation,
        distanceFilter: kCLDistanceFilterNone,
        activityType: .automotiveNavigation,
        allowsBackgroundUpdates: true,
        pausesAutomatically: false,
        showsBackgroundIndicator: true
    )
}

extension TrackingConfiguration: _ShowsBackgroundIndicatorProviding {
    public var showsBackgroundLocationIndicator: Bool {
        showsBackgroundIndicator
    }
}
