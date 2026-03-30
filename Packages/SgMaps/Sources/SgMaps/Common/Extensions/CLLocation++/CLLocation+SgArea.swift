//
//  CLLocation+SgArea.swift
//  SgMaps
//
//  Created by Aung Ko Min on 30/11/24.
//

import CoreLocation

public extension CLLocation {
    var sgArea: SgArea {
        SgArea(self) ?? .init(name: "", geometry: .polygon(.init(verticies: [])))
    }
}

public extension SgArea {
    init?(_ location: CLLocation) {
        let area = SgArea.allCases.first(where: { $0.geometry.isContain(location.coordinate) })
        if let area {
            self = area
        } else {
            return nil
        }
    }
}
