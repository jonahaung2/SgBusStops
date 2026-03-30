//
//  MapItem.swift
//
//
//  Created by Aung Ko Min on 4/8/24.
//

import CoreLocation
import Foundation

public struct MapItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let location: CLLocation

    public init(_ name: String, location: CLLocation) {
        id = Self.makeID(name: name, coordinate: location.coordinate)
        self.name = name
        self.location = location
    }

    public static func == (lhs: MapItem, rhs: MapItem) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public extension MapItem {
    init(_ name: String, coordinate: CLLocationCoordinate2D) {
        self.init(name, location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }

    static func centerCoordinate(for items: [MapItem]) -> CLLocationCoordinate2D {
        let region = PolygonRegion(verticies: items.map(\.location.coordinate))
        return region.center
    }
}

private extension MapItem {
    static func makeID(name: String, coordinate: CLLocationCoordinate2D) -> String {
        let latitude = String(format: "%.6f", coordinate.latitude)
        let longitude = String(format: "%.6f", coordinate.longitude)
        return "\(name)|\(latitude)|\(longitude)"
    }
}
