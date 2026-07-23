//  BusStop++.swift
//
//  Copyright © 2026 Aung Ko Min.
//

//
//  BusStop++.swift
//  Services
//
//  Created by Aung Ko Min on 19/3/26.
//
import Models
import CoreLocation

public extension Stop {
    func distance(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        coordinate.distance(to: self.coordinate)
    }
}
