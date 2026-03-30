//
//  Date++.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 29/3/26.
//

import Foundation

extension Date {
	var secondsFromNow: Int { Int(self.timeIntervalSince(.now))}
}
