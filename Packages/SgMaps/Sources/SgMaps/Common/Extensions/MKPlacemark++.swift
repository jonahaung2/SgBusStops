//
//  MKPlacemark++.swift
//  SgMaps
//
//  Created by Aung Ko Min on 25/9/24.
//

import Contacts
import MapKit

extension MKPlacemark {
    var formattedAddress: String? {
        guard let postalAddress else { return nil }
        return CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress).replacingOccurrences(of: "\n", with: " ")
    }
}
