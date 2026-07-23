//  BusStopAPI.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import Foundation

public enum BusStopAPI {
    struct BusStopsRequest: NetworkRequest {
        typealias Response = BusStopModel.Response

        var path: String {
            "ltaodataservice/BusStops"
        }

        var queryItems: [URLQueryItem]?
        var method: HTTPMethod {
            .get
        }

        init(top: Int, skip: Int = 0) {
            var items: [URLQueryItem] = [
                .init(name: "$top", value: String(top))
            ]
            if skip > 0 {
                items.append(.init(name: "$skip", value: String(skip)))
            }
            queryItems = items
        }
    }
}
