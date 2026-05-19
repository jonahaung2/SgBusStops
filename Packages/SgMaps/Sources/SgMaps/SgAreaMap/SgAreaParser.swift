//  SgAreaParser.swift
//
//  Copyright © 2024 Aung Ko Min.
//

import Foundation
import CoreLocation

enum SgAreaParser {
    typealias StringAny = [String: Any]

    static func load() -> [SgArea] {
        guard
            let url = Bundle
                .module
                .url(
                    forResource: SgMaps.SgArea.Resources.file_name,
                    withExtension: SgMaps.SgArea.Resources.file_ext
                ) else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(
                with: data,
                options: .mutableLeaves
            )
            guard
                let dic = json as? StringAny,
                let features = dic["features"] as? [StringAny] else {
                return []
            }
            return features.compactMap { polygons($0) }
        } catch {
            return []
        }
    }
}

/// Helpers
private extension SgAreaParser {
    /// Polygons
    private static func polygons(_ dic: StringAny) -> SgArea? {
        guard
            let properties = dic["properties"] as? StringAny,
            let name = properties["name"] as? String,
            let geometryDict = dic["geometry"] as? StringAny,
            let geoType = geometryDict["type"] as? String else {
            return nil
        }
        switch geoType {
        case "Polygon":
            return SgArea(
                name: name,
                geometry: .polygon(
                    .init(
                        verticies: polygon(geometryDict)
                    )
                )
            )
        case "MultiPolygon":
            return SgArea(
                name: name,
                geometry: .multiPolygon(
                    multiPolygon(geometryDict)
                        .map { .init(verticies: $0) }
                )
            )
        default:
            return nil
        }
    }

    /// Polygon
    private static func polygon(_ dic: StringAny) -> [CLLocationCoordinate2D] {
        guard let coordinates = dic["coordinates"] as? [[[Double]]] else {
            return []
        }
        return points(coordinates)
    }

    /// Multi-Polygon
    private static func multiPolygon(_ dic: StringAny) -> [[CLLocationCoordinate2D]] {
        guard let coordinates = dic["coordinates"] as? [[[[Double]]]] else {
            return []
        }
        return coordinates.map(points)
    }

    /// Points
    private static func points(_ points: [[[Double]]]) -> [CLLocationCoordinate2D] {
        points.flatMap(\.self).compactMap { point in
            guard let longitude = point.first, let latitude = point.last, longitude != latitude else {
                return nil
            }
            return .init(latitude: latitude, longitude: longitude)
        }
    }
}
