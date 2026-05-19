//  MKPlacemark++.swift
//
//  Copyright © 2024 Aung Ko Min.
//

import MapKit
import Contacts

extension MKPlacemark {
    var formattedAddress: String? {
        guard let postalAddress else { return nil }
        return CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress).replacingOccurrences(of: "\n", with: " ")
    }
}
