//  SgArea.swift
//
//  Copyright © 2024 Aung Ko Min.
//

import Foundation
import CoreLocation

public struct SgArea: Conformable {
    public var rawValue: String {
        name
    }

    public var name: String
    public let geometry: Geometry
    public init(name: String, geometry: Geometry) {
        self.name = name
        self.geometry = geometry
    }
}

public extension SgArea {
    enum Geometry: Conformable {
        case polygon(PolygonRegion)
        case multiPolygon([PolygonRegion])
        public var id: AnyHashable {
            switch self {
            case let .polygon(region):
                region.id
            case let .multiPolygon(regions):
                regions
                    .compactMap(\.id)
            }
        }

        public var centerCoordinate: CLLocationCoordinate2D {
            switch self {
            case let .polygon(region):
                return region.center
            case let .multiPolygon(regions):
                let region = PolygonRegion(verticies: regions.flatMap(\.verticies))
                return region.center
            }
        }

        public func isContain(_ coordinate: CLLocationCoordinate2D) -> Bool {
            switch self {
            case let .polygon(region):
                region.isPointInside(coordinate)
            case let .multiPolygon(regions):
                regions.first(where: { $0.isPointInside(coordinate) }) != nil
            }
        }
    }
}

public extension SgArea {
    init?(_ coordinate: CLLocationCoordinate2D) {
        if let item = Self.allCases.first(where: { $0.geometry.isContain(coordinate) }) {
            self = item
        } else {
            return nil
        }
    }

    init?(_ areaString: String) {
        let name = areaString.replace("_", with: " ").uppercased()
        if let found = Self.allCases.first(where: { $0.name == name }) {
            self = found
        } else {
            return nil
        }
    }
}

extension SgArea: CaseIterable {
    public static let allCases: [SgArea] = SgAreaParser.load()
//    var area: Area {
//        let rawValue = name.replace(" ", with: "_").capitalized
//        return .init(rawValue: rawValue)!
//    }
}

extension SgArea: Hashable, Identifiable {
    public var id: AnyHashable {
        name
    }

    public static func == (lhs: SgArea, rhs: SgArea) -> Bool {
        lhs.name == rhs.name && lhs.geometry.id == rhs.geometry.id
    }

    public func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }
}
