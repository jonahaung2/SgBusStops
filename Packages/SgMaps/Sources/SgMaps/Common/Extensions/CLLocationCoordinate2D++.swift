//  CLLocationCoordinate2D++.swift
//
//  Copyright © 2024 Aung Ko Min.
//

import Foundation
import CoreLocation

public extension CLLocationCoordinate2D {
    var location: CLLocation {
        .init(latitude: latitude, longitude: longitude)
    }

    static let singapore: CLLocationCoordinate2D = .init(latitude: 1.282302, longitude: 103.858528)
}

extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}
