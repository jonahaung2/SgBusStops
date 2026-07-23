//  BusRoutingInfo.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public struct BusRoutingInfo: Codable, Identifiable, Hashable, Sendable {

    public var id: String {
        "\(serviceNo)-\(direction)-\(stopSequence)"
    }

    public let serviceNo: String
    public let operatorType: BusOperator
    public let direction: BusDirection
    public let stopSequence: Int
    public let busStopCode: String
    public let distance: Double

    public let weekday: BusTiming?
    public let saturday: BusTiming?
    public let sunday: BusTiming?

    public init(
        serviceNo: String,
        operatorType: BusOperator,
        direction: BusDirection,
        stopSequence: Int,
        busStopCode: String,
        distance: Double,
        weekday: BusTiming? = nil,
        saturday: BusTiming? = nil,
        sunday: BusTiming? = nil
    ) {
        self.serviceNo = serviceNo
        self.operatorType = operatorType
        self.direction = direction
        self.stopSequence = stopSequence
        self.busStopCode = busStopCode
        self.distance = distance
        self.weekday = weekday
        self.saturday = saturday
        self.sunday = sunday
    }

    enum CodingKeys: String, CodingKey {
        case serviceNo = "ServiceNo"
        case operatorType = "Operator"
        case direction = "Direction"
        case stopSequence = "StopSequence"
        case busStopCode = "BusStopCode"
        case distance = "Distance"
        case wdFirst = "WD_FirstBus"
        case wdLast = "WD_LastBus"
        case satFirst = "SAT_FirstBus"
        case satLast = "SAT_LastBus"
        case sunFirst = "SUN_FirstBus"
        case sunLast = "SUN_LastBus"
    }

    // Custom decoding to map first/last buses
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        serviceNo = try c.decode(String.self, forKey: .serviceNo)
        operatorType = try .init(rawValue: c.decode(String.self, forKey: .operatorType)) ?? .unknown
        direction = try .init(rawValue: c.decode(Int.self, forKey: .direction)) ?? .none
        stopSequence = try c.decode(Int.self, forKey: .stopSequence)
        busStopCode = try c.decode(String.self, forKey: .busStopCode)
        distance = try c.decode(Double.self, forKey: .distance)

        // Decode timings
        let wdFirst = try c.decodeIfPresent(String.self, forKey: .wdFirst)
        let wdLast = try c.decodeIfPresent(String.self, forKey: .wdLast)
        weekday = (wdFirst != nil && wdLast != nil) ? BusTiming(firstBus: wdFirst!, lastBus: wdLast!) : nil

        let satFirst = try c.decodeIfPresent(String.self, forKey: .satFirst)
        let satLast = try c.decodeIfPresent(String.self, forKey: .satLast)
        saturday = (satFirst != nil && satLast != nil) ? BusTiming(firstBus: satFirst!, lastBus: satLast!) : nil

        let sunFirst = try c.decodeIfPresent(String.self, forKey: .sunFirst)
        let sunLast = try c.decodeIfPresent(String.self, forKey: .sunLast)
        sunday = (sunFirst != nil && sunLast != nil) ? BusTiming(firstBus: sunFirst!, lastBus: sunLast!) : nil
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(serviceNo, forKey: .serviceNo)
        try c.encode(operatorType, forKey: .operatorType)
        try c.encode(direction, forKey: .direction)
        try c.encode(stopSequence, forKey: .stopSequence)
        try c.encode(busStopCode, forKey: .busStopCode)
        try c.encode(distance, forKey: .distance)

        try c.encodeIfPresent(weekday?.firstBus, forKey: .wdFirst)
        try c.encodeIfPresent(weekday?.lastBus, forKey: .wdLast)

        try c.encodeIfPresent(saturday?.firstBus, forKey: .satFirst)
        try c.encodeIfPresent(saturday?.lastBus, forKey: .satLast)

        try c.encodeIfPresent(sunday?.firstBus, forKey: .sunFirst)
        try c.encodeIfPresent(sunday?.lastBus, forKey: .sunLast)
    }
}

//// MARK: - Coding Keys
//
//extension BusRoutingInfo {
//	fileprivate enum CodingKeys: String, CodingKey {
//		case serviceNo = "ServiceNo"
//		case operatorType = "Operator"
//		case direction = "Direction"
//		case stopSequence = "StopSequence"
//		case busStopCode = "BusStopCode"
//		case distance = "Distance"
//
//		case wdFirst = "WD_FirstBus"
//		case wdLast = "WD_LastBus"
//		case satFirst = "SAT_FirstBus"
//		case satLast = "SAT_LastBus"
//		case sunFirst = "SUN_FirstBus"
//		case sunLast = "SUN_LastBus"
//	}
//}
//
//// MARK: - Encode
//
//extension BusRoutingInfo {
//	public func encode(to encoder: Encoder) throws {
//		var c = encoder.container(keyedBy: CodingKeys.self)
//
//		try c.encode(serviceNo, forKey: .serviceNo)
//		try c.encode(operatorType, forKey: .operatorType)
//		try c.encode(direction.rawValue, forKey: .direction)
//		try c.encode(stopSequence, forKey: .stopSequence)
//		try c.encode(busStopCode, forKey: .busStopCode)
//		try c.encode(distance, forKey: .distance)
//
//		// Encode timings
//		try c.encodeIfPresent(weekday?.firstBus?.raw, forKey: .wdFirst)
//		try c.encodeIfPresent(weekday?.lastBus?.raw, forKey: .wdLast)
//
//		try c.encodeIfPresent(saturday?.firstBus?.raw, forKey: .satFirst)
//		try c.encodeIfPresent(saturday?.lastBus?.raw, forKey: .satLast)
//
//		try c.encodeIfPresent(sunday?.firstBus?.raw, forKey: .sunFirst)
//		try c.encodeIfPresent(sunday?.lastBus?.raw, forKey: .sunLast)
//	}
//}
//
//// MARK: - Decode
//
//extension BusRoutingInfo {
//	public init(from decoder: Decoder) throws {
//		let c = try decoder.container(keyedBy: CodingKeys.self)
//
//		serviceNo = try c.decode(String.self, forKey: .serviceNo)
//		operatorType = try c.decode(BusOperator.self, forKey: .operatorType)
//		direction = .init(rawValue: try c.decode(Int.self, forKey: .direction)) ?? .none
//		stopSequence = try c.decode(Int.self, forKey: .stopSequence)
//		busStopCode = try c.decode(String.self, forKey: .busStopCode)
//		distance = try c.decodeIfPresent(Double.self, forKey: .distance) ?? 0
//
//		func decodeTime(_ key: CodingKeys) -> BusTime? {
//			guard let raw = try? c.decodeIfPresent(String.self, forKey: key)
//			else { return nil }
//			let value = raw
//			return BusTime(raw: value)
//		}
//
//		let wdFirst = decodeTime(.wdFirst)
//		let wdLast = decodeTime(.wdLast)
//		weekday = (wdFirst == nil && wdLast == nil) ? nil : BusTiming(firstBus: wdFirst, lastBus: wdLast)
//
//		let satFirst = decodeTime(.satFirst)
//		let satLast = decodeTime(.satLast)
//		saturday = (satFirst == nil && satLast == nil) ? nil : BusTiming(firstBus: satFirst, lastBus: satLast)
//
//		let sunFirst = decodeTime(.sunFirst)
//		let sunLast = decodeTime(.sunLast)
//		sunday = (sunFirst == nil && sunLast == nil) ? nil : BusTiming(firstBus: sunFirst, lastBus: sunLast)
//	}
//}

// MARK: - Response Wrapper

public extension BusRoutingInfo {
    struct Response: Codable, Sendable {
        public let value: [BusRoutingInfo]

        public init(value: [BusRoutingInfo]) {
            self.value = value
        }
    }
}
