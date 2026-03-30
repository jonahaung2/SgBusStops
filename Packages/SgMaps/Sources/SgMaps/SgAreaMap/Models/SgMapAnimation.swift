//
//  SgMapAnimation.swift
//
//
//  Created by Aung Ko Min on 31/7/24.
//

import Foundation
import MapKit

public struct SgMapAnimation {
    public var coordinate: CLLocationCoordinate2D
    public var distance: Double
    public var pitch: Double

    public init(
        _ coordinate: CLLocationCoordinate2D = .singapore,
        distance: Double = 80000,
        pitch: Double = 0.2,
    ) {
        self.coordinate = coordinate
        self.distance = distance
        self.pitch = pitch
    }
}

extension SgMapAnimation: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
        hasher.combine(distance)
        hasher.combine(pitch)
    }
}
