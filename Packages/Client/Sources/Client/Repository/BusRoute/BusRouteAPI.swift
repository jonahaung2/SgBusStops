//  BusRouteAPI.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import Foundation

public enum BusRouteAPI {
    struct Request: NetworkRequest {
        typealias Response = BusRoutingInfo.Response
        var path: String {
            "ltaodataservice/BusRoutes"
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
