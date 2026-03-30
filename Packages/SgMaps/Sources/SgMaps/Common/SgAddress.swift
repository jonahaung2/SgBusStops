//
//  SgAddress.swift
//  SgMaps
//
//  Created by Aung Ko Min on 24/9/24.
//

import Foundation
import MapKit

protocol Conformable: Equatable, Sendable, Hashable {}
//
// public struct SgAddress: Conformable {
//
//    public var address: SgAddress.Address
//    public var area: SgArea
//    public var nearestMRT: SgAddress.NearestMRT
//    public var geoInfo: SgAddress.GeoInfo
//    public var identifier: String?
//
//    public init(address: SgAddress.Address, geoInfo: SgAddress.GeoInfo, area: SgArea, nearestMRT: SgAddress.NearestMRT) {
//        self.area = area
//        self.nearestMRT = nearestMRT
//        self.address = address
//        self.geoInfo = geoInfo
//    }
//
//    public init(_ mapItem: MKMapItem) {
//        let placmark = mapItem.placemark
//        let location = mapItem.placemark.location ?? .init(latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
//        let area = location.sgArea
//        let nearestMRT = location.nearestMRT
//        let postalCode = mapItem.placemark.postalCode ?? ""
//        let address = Address.init(text: placmark.formattedAddress ?? "", postal: postalCode)
//        let geoInfo = GeoInfo(location: location)
//        self.init(address: address, geoInfo: geoInfo, area: area, nearestMRT: nearestMRT)
//        if #available(iOS 18.0, *) {
//            self.identifier = mapItem.identifier?.rawValue
//        }
//    }
//
//    public var isValid: Bool {
//        address.postal.count == 6 && Int(address.postal) != nil
//    }
//    public var isEmpty: Bool {
//        !isValid
//    }
// }
//
// public extension SgAddress {
//
//    public struct Address: Conformable {
//        public var text: String
//        public var postal: String
//        public init(text: String, postal: String) {
//            self.text = text
//            self.postal = postal
//        }
//    }
//    public struct NearestMRT: Conformable {
//        public var mrt: String
//        public var distance: Int
//        public init(mrt: String, distance: Int) {
//            self.mrt = mrt
//            self.distance = distance
//        }
//        public static func nearestMRT(from location: CLLocation) -> SgAddress.NearestMRT {
//            let mrts = MRT.allValues
//            var closestMRT: MRT?
//            var smallestDistance: CLLocationDistance?
//            for mrt in mrts {
//                let mrtLocation = mrt.location
//                let distance = location.distance(from: mrtLocation)
//                if smallestDistance == nil || distance < smallestDistance ?? .init() {
//                    closestMRT = mrt
//                    smallestDistance = distance
//                }
//            }
//            if let closestMRT, let smallestDistance {
//                return .init(mrt: closestMRT.name, distance: smallestDistance.minutes)
//            }
//            return .init(mrt: closestMRT?.name ?? "", distance: 0)
//        }
//    }
//    public struct GeoInfo: Conformable {
//        public var location: CLLocation
//        public init(location: CLLocation) {
//            self.location = location
//        }
//
//    }
// }
//
// public extension SgAddress {
//    static let empty: SgAddress = .init(address: .init(text: "", postal: ""), geoInfo: .init(location: .init(latitude: CLLocationCoordinate2D.singapore.latitude, longitude: CLLocationCoordinate2D.singapore.longitude)), area: .init(name: "", geometry: .multiPolygon([])), nearestMRT: .init(mrt: "", distance: 0))
// }
