//  MapAnnotationItem.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import CoreLocation

public struct MapAnnotationItem: Identifiable, Sendable, Hashable {
    public let id: String
    public let coordinate: CLLocationCoordinate2D
    public let title: String

    public init(
        id: String,
        coordinate: CLLocationCoordinate2D,
        title: String
    ) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
    }

    public static func == (lhs: MapAnnotationItem, rhs: MapAnnotationItem) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.coordinate.latitude == rhs.coordinate.latitude &&
            lhs.coordinate.longitude == rhs.coordinate.longitude
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}
