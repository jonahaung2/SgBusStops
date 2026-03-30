//
//  MrtLine.swift
//
//
//  Created by Aung Ko Min on 1/8/24.
//

import CoreLocation
import Foundation
import SwiftUI

public enum MRTLine: String, Codable, Identifiable, CaseIterable, Hashable, Sendable {
    public var id: String {
        rawValue
    }

    case CC, NS, DT, EW, NE, TE

    public var code: String {
        rawValue
    }

    public var hashColor: String {
        switch self {
        case .CC:
            "#FFA500"
        case .NS:
            "#ff0000"
        case .DT:
            "#0067B2"
        case .EW:
            "#00aa00"
        case .NE:
            "#8B008B"
        case .TE:
            "#9D5B25"
        }
    }

    @available(macOS 10.15, *)
    public var color: Color {
        .init(hex: hashColor)
    }

    public var name: String {
        switch self {
        case .CC:
            "Circle Line"
        case .NS:
            "North-Sourth Line"
        case .DT:
            "Downtown Line"
        case .EW:
            "East-West Line"
        case .NE:
            "North-East Line"
        case .TE:
            "Thomson-East Coast Line"
        }
    }

    public var polygonRegion: PolygonRegion {
        .init(verticies: mrts.map(\.coordinate))
    }

    public var coordinates: [CLLocationCoordinate2D] {
        polygonRegion.verticies
    }

    public var mrts: [MRT] {
        let items = MRT.allValues.filter { mrt in
            mrt.mainSymbol(for: self) != nil
        }
        return items.sorted { lhs, rhs in
            lhs.codeInt(for: self) < rhs.codeInt(for: self)
        }
    }
}

public extension Color {
    init(hex: String) {
        let hexSanitized = hex
            .replacingOccurrences(of: "#", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        var rgb: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            self.init("AccentColor")
            return
        }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF00_0000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF_0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000_FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x0000_00FF) / 255.0
        }
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
