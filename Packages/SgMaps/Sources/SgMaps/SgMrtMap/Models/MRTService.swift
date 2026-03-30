//
//  MRTService.swift
//
//
//  Created by Aung Ko Min on 4/8/24.
//

import CoreLocation
import Foundation

public struct MRTService: Hashable, Identifiable {
    public var id: String {
        line.code + mrts.count.description
    }

    public let line: MRTLine
    public let mrts: [MRT]
    public let polygonRegion: PolygonRegion

    public init(_ line: MRTLine) {
        self.line = line
        mrts = line.mrts
        polygonRegion = .init(verticies: line.mrts.map(\.coordinate))
    }

    public var coordinates: [CLLocationCoordinate2D] {
        polygonRegion.verticies
    }
}
