//  SgGeoCoder.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import MapKit
import Contacts
import Foundation

public actor SgGeoCoder {
    public init() {}

    public func getAddress(from postalCode: String) async throws -> String {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = postalCode
        let response = try await MKLocalSearch(request: request).start()
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *),
           let mapItem = response.mapItems.last,
           let address = mapItem.formattedAddress {
            return address
        }

        let location = CLLocation(
            latitude: response.boundingRegion.center.latitude,
            longitude: response.boundingRegion.center.longitude
        )
        return try await createLocationInfo(from: location)
    }

    private func generateAddress(placemark: CLPlacemark) -> String {
        if let postalAddress = placemark.postalAddress {
            return CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                .replacingOccurrences(of: "\n", with: " ")
        }
        var components = [String]()
        if let value = placemark.subThoroughfare {
            components.append(value)
        }
        if let value = placemark.thoroughfare, value != placemark.name {
            components.append(value)
        }
        if let value = placemark.subLocality {
            components.append(value)
        }
        if let value = placemark.locality {
            components.append(value)
        }
        if let value = placemark.postalCode {
            components.append(value)
        }
        if let value = placemark.administrativeArea {
            components.append(value)
        }
        return components.joined(separator: ", ")
    }
}

public extension SgGeoCoder {
    func createLocationInfo(from location: CLLocation) async throws -> String {
        if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0) {
            return try await createLegacyLocationInfo(from: location)
        }

        guard let request = MKReverseGeocodingRequest(location: location),
              let address = try await request.mapItems.first?.formattedAddress else {
            throw SgMapError.invalidPlscemark
        }
        return address
    }

    @available(iOS, introduced: 2.0, deprecated: 26.0)
    @available(macOS, introduced: 10.8, deprecated: 26.0)
    @available(tvOS, introduced: 9.0, deprecated: 26.0)
    @available(watchOS, introduced: 2.0, deprecated: 26.0)
    @available(visionOS, introduced: 1.0, deprecated: 26.0)
    private func createLegacyLocationInfo(from location: CLLocation) async throws -> String {
        let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
        guard let placemark = placemarks.first else {
            throw SgMapError.invalidPlscemark
        }
        return generateAddress(placemark: placemark)
    }

    func createLocationInfo(from adedressText: String) async throws -> String {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = adedressText
        let response = try await MKLocalSearch(request: request).start()
        let region = response.boundingRegion
        let location = CLLocation(
            latitude: region.center.latitude,
            longitude: region.center.longitude
        )
        return try await createLocationInfo(from: location)
    }

    func createLocation(from adedressText: String) async throws -> CLLocation {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = adedressText
        let response = try await MKLocalSearch(request: request).start()
        let region = response.boundingRegion
        return CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
    }

}

public enum SgMapError: Error {
    case invalidPlscemark
    case jSONSerialization
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension MKMapItem {
    var formattedAddress: String? {
        addressRepresentations?.fullAddress(includingRegion: false, singleLine: true)
            ?? address?.fullAddress
    }
}

