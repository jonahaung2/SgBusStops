//  SgMrt.swift
//
//  Copyright © 2024 Aung Ko Min.
//

import MapKit
import SwiftUI

public struct MRT: Codable, Sendable {
    public let id: Int
    public let name: String
    public let type: Int
    public let latitude: Double
    public let longitude: Double
    public let symbol: [Symbol]

    public init(id: Int, name: String, type: Int, latitude: Double, longitude: Double, symbol: [Symbol]) {
        self.id = id
        self.name = name
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.symbol = symbol
    }

    public static let allValues: [MRT] = SgMrtParser.mrts
    public static let allValueStrings: [String] = Array(Set(allValues.map(\.name))).sorted() + [""]
}

extension MRT: Identifiable, Hashable {
    public struct Symbol: Codable, Hashable, Identifiable, Sendable {
        public var id: String {
            code
        }

        public let code: String
        public let color: String
        @available(macOS 10.15, *)
        public var swiftColor: Color {
            Color(hex: color)
        }
    }
}

public extension MRT {
    func mainSymbol(for mrtLine: MRTLine) -> MRT.Symbol? {
        symbol.first {
            $0.code.hasPrefix(mrtLine.code)
        }
    }

    func codeInt(for mrtLine: MRTLine) -> Int {
        guard let mainSymbol = mainSymbol(for: mrtLine) else { return 0 }
        let trimmed = mainSymbol.code.replace(mrtLine.code, with: "")
        return Int(trimmed) ?? 0
    }
}

extension MRT {
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        .init(latitude: latitude, longitude: longitude)
    }
}
