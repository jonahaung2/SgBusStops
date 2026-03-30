//
//  CLLocationCoordinate2D++.swift
//
//
//  Created by Aung Ko Min on 5/8/24.
//

import CoreLocation
import Foundation

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
