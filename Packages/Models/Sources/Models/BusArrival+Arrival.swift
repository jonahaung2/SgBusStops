//  BusArrival+Arrival.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation
import CoreLocation

public extension BusArrival {
    struct Arrival: Codable, Sendable, Identifiable, Hashable {
        public var id: String {
            (originCode ?? "") + (destinationCode ?? "")
        }

        public let originCode: String?
        public let destinationCode: String?
        public let estimatedArrival: Date?
        public let monitored: Bool
        public let latitude: Double?
        public let longitude: Double?
        public let visitNumber: Int?
        public let load: BusLoad?
        public let feature: BusFeature?
        public let type: BusType?

        enum CodingKeys: String, CodingKey {
            case originCode = "OriginCode"
            case destinationCode = "DestinationCode"
            case estimatedArrival = "EstimatedArrival"
            case monitored = "Monitored"
            case latitude = "Latitude"
            case longitude = "Longitude"
            case visitNumber = "VisitNumber"
            case load = "Load"
            case feature = "Feature"
            case type = "Type"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            originCode = try container.decodeIfPresent(String.self, forKey: .originCode)
            destinationCode = try container.decodeIfPresent(String.self, forKey: .destinationCode)
            estimatedArrival = Arrival.decodeFlexibleDate(in: container, forKey: .estimatedArrival)
            latitude = Arrival.decodeFlexibleDouble(in: container, forKey: .latitude)
            longitude = Arrival.decodeFlexibleDouble(in: container, forKey: .longitude)
            visitNumber = Arrival.decodeFlexibleInt(in: container, forKey: .visitNumber)
            load = Arrival.decodeFlexibleLoad(in: container, forKey: .load)
            feature = Arrival.decodeFlexibleFeature(in: container, forKey: .feature)
            type = Arrival.decodeFlexibleType(in: container, forKey: .type)

            monitored = if let boolValue = try? container.decode(Bool.self, forKey: .monitored) {
                boolValue
            } else if let intValue = try? container.decode(Int.self, forKey: .monitored) {
                intValue != 0
            } else if let stringValue = try? container.decode(String.self, forKey: .monitored) {
                switch stringValue.lowercased() {
                case "1",
                     "true",
                     "y",
                     "yes":
                    true
                default:
                    false
                }
            } else {
                false
            }
        }

        private static func decodeFlexibleDouble(
            in container: KeyedDecodingContainer<CodingKeys>,
            forKey key: CodingKeys
        ) -> Double? {
            if let value = try? container.decodeIfPresent(Double.self, forKey: key) {
                return value
            }
            if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
                return Double(value)
            }
            if let value = try? container.decodeIfPresent(String.self, forKey: key) {
                return Double(value.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            return nil
        }

        private static func decodeFlexibleInt(
            in container: KeyedDecodingContainer<CodingKeys>,
            forKey key: CodingKeys
        ) -> Int? {
            if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
                return value
            }
            if let value = try? container.decodeIfPresent(Double.self, forKey: key) {
                return Int(value)
            }
            if let value = try? container.decodeIfPresent(String.self, forKey: key) {
                return Int(value.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            return nil
        }

        private static func decodeFlexibleDate(
            in container: KeyedDecodingContainer<CodingKeys>,
            forKey key: CodingKeys
        ) -> Date? {
            if let value = try? container.decodeIfPresent(Date.self, forKey: key) {
                return value
            }
            if let value = try? container.decodeIfPresent(Double.self, forKey: key) {
                return Date(timeIntervalSince1970: value)
            }
            if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
                return Date(timeIntervalSince1970: Double(value))
            }
            if let raw = try? container.decodeIfPresent(String.self, forKey: key) {
                let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                if value.isEmpty {
                    return nil
                }
                if let parsed = parseISO8601(value) {
                    return parsed
                }
            }
            return nil
        }

        private static func parseISO8601(_ value: String) -> Date? {
            let withFractional = ISO8601DateFormatter()
            withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let parsed = withFractional.date(from: value) {
                return parsed
            }

            let standard = ISO8601DateFormatter()
            standard.formatOptions = [.withInternetDateTime]
            return standard.date(from: value)
        }

        private static func decodeFlexibleLoad(
            in container: KeyedDecodingContainer<CodingKeys>,
            forKey key: CodingKeys
        ) -> BusLoad? {
            if let value = try? container.decodeIfPresent(BusLoad.self, forKey: key) {
                return value
            }
            if let raw = try? container.decodeIfPresent(String.self, forKey: key) {
                let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                guard !normalized.isEmpty else { return nil }
                return BusLoad(rawValue: normalized)
            }
            return nil
        }

        private static func decodeFlexibleFeature(
            in container: KeyedDecodingContainer<CodingKeys>,
            forKey key: CodingKeys
        ) -> BusFeature? {
            if let value = try? container.decodeIfPresent(BusFeature.self, forKey: key) {
                return value
            }
            if let raw = try? container.decodeIfPresent(String.self, forKey: key) {
                let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                guard !normalized.isEmpty else { return nil }
                return BusFeature(rawValue: normalized)
            }
            return nil
        }

        private static func decodeFlexibleType(
            in container: KeyedDecodingContainer<CodingKeys>,
            forKey key: CodingKeys
        ) -> BusType? {
            if let value = try? container.decodeIfPresent(BusType.self, forKey: key) {
                return value
            }
            if let raw = try? container.decodeIfPresent(String.self, forKey: key) {
                let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                guard !normalized.isEmpty else { return nil }
                return BusType(rawValue: normalized)
            }
            return nil
        }

        public func arrivalSeconds(now: Date = .now) -> Int? {
            guard let eta = estimatedArrival else {
                return nil
            }
            return Int(eta.timeIntervalSince(now))
        }

        public func arrivalMinutes(now: Date = .now) -> Int? {
            guard let seconds = arrivalSeconds(now: now) else {
                return nil
            }
            if seconds <= -30 {
                return nil
            }

            if seconds <= 60 {
                return 1
            }
            return Int(seconds / 60)
        }
    }

}

public extension BusArrival.Arrival {
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
