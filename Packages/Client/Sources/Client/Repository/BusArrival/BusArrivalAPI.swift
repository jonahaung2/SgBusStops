//  BusArrivalAPI.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import Foundation

public enum BusArrivalAPI {
    public struct Request: NetworkRequest {
        public typealias Response = BusArrivalListResponse

        public var path: String {
            "ltaodataservice/v3/BusArrival"
        }

        public var method: HTTPMethod {
            .get
        }

        public var queryItems: [URLQueryItem]? {
            if let busServiceNumber {
                return [
                    .init(name: "BusStopCode", value: busStopCode),
                    .init(name: "ServiceNo", value: busServiceNumber)
                ]
            }
            return [
                .init(name: "BusStopCode", value: busStopCode)
            ]
        }

        private let busStopCode: String
        private let busServiceNumber: String?

        public init(busStopCode: String) {
            self.busStopCode = busStopCode
            busServiceNumber = nil
        }

        public init(busStopCode: String, busServiceNumber: String) {
            self.busStopCode = busStopCode
            self.busServiceNumber = busServiceNumber
        }
    }

    public struct BusArrivalListResponse: Codable, Sendable {
        public let busStopCode: String
        public let services: [BusArrival]

        enum CodingKeys: String, CodingKey {
            case busStopCode = "BusStopCode"
            case services = "Services"
        }
    }
}
