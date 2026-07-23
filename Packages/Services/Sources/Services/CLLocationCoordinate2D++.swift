//  CLLocationCoordinate2D++.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import simd
import CoreLocation

public extension CLLocationCoordinate2D {

    func distance(to other: CLLocationCoordinate2D) -> Double {
        DistanceEngine.fastDistance(from: self, to: other)
    }

}

public enum DistanceEngine {

    // Earth radius in KM
    private static let earthRadius = 6371.0

    // Switch threshold (km)
    private static let threshold: Double = 5.0

    // MARK: - Public API

    public static func distance(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D,
        roundedTo decimals: Int? = 2
    ) -> Double {

        guard isValid(from), isValid(to) else { return 0 }

        let approx = fastDistance(from: from, to: to)

        let distance =
            approx < threshold
                ? approx // ⚡ fast path
                : haversine(from: from, to: to) // 🎯 accurate path

        guard let decimals else { return distance }
        return round(distance, to: decimals)
    }
}

// MARK: - Private Helpers

private extension DistanceEngine {

    static func isValid(_ coord: CLLocationCoordinate2D) -> Bool {
        coord.latitude.isFinite && coord.longitude.isFinite && abs(coord.latitude) <= 90
            && abs(coord.longitude) <= 180
    }

    // ⚡ Fast (Equirectangular)
    static func fastDistance(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Double {

        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let dLat = lat2 - lat1
        let dLon = (to.longitude - from.longitude) * .pi / 180

        let x = dLon * cos((lat1 + lat2) / 2)
        let y = dLat

        return sqrt(x * x + y * y) * earthRadius
    }

    // 🎯 Accurate (Haversine)
    static func haversine(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Double {

        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let dLat = lat2 - lat1
        let dLon = (to.longitude - from.longitude) * .pi / 180

        let sinLat = sin(dLat / 2)
        let sinLon = sin(dLon / 2)

        var a = sinLat * sinLat + cos(lat1) * cos(lat2) * sinLon * sinLon

        // 🔥 critical stability fix
        a = min(1.0, max(0.0, a))

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadius * c
    }

    static func round(_ value: Double, to decimals: Int) -> Double {
        let factor = pow(10.0, Double(decimals))
        return (value * factor).rounded() / factor
    }
}
