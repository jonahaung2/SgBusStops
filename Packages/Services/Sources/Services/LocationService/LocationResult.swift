//  LocationResult.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SgMaps
import CoreLocation

public struct LocationResult: Sendable, Hashable, Equatable, Identifiable {
    public var id: Double { latitude + longitude }

    public let latitude: Double
    public let longitude: Double
    public let horizontalAccuracy: CLLocationAccuracy
    public let timestamp: Date
    public let speed: CLLocationSpeed
    public let course: CLLocationDirection
    public let source: LocationSource

    public init(
        latitude: Double,
        longitude: Double,
        horizontalAccuracy: CLLocationAccuracy,
        timestamp: Date,
        speed: CLLocationSpeed,
        course: CLLocationDirection,
        source: LocationSource
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
        self.timestamp = timestamp
        self.speed = speed
        self.course = course
        self.source = source
    }

    public static let `default`: LocationResult = .init(
        location: .init(
            latitude: CLLocationCoordinate2D.singapore.latitude,
            longitude: CLLocationCoordinate2D.singapore.longitude
        ),
        source: .mock
    )

}

public extension LocationResult {
    init(location: CLLocation, source: LocationSource) {
        self.init(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            horizontalAccuracy: location.horizontalAccuracy,
            timestamp: location.timestamp,
            speed: location.speed,
            course: location.course,
            source: source
        )
    }

    var clLocation: CLLocation {
        CLLocation(
            latitude: latitude,
            longitude: longitude
        )
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

public extension LocationResult {
    func distance(to other: CLLocation) -> FloatingPointFormatStyle<Double>.FormatOutput {
        (clLocation.distance(from: other) / 1000).formatted(.number.precision(.fractionLength(2)))
    }
}

public extension LocationResult {
    var analyticsPayload: [String: Any] {
        [
            "accuracy_bucket": accuracyBucket,
            "source": source.rawValue,
            "timestamp": timestamp.timeIntervalSince1970
        ]
    }

    private var accuracyBucket: String {
        switch horizontalAccuracy {
        case ..<20: "very_high"
        case ..<50: "high"
        case ..<100: "medium"
        default: "low"
        }
    }
}
