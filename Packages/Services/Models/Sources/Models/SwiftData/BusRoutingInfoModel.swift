//  BusRoutingInfoModel.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI
import SwiftData

@Model
public final class BusRoutingInfoModel {
    @Attribute(.unique) public var id: String
    public var serviceNo: String
    public var operatorType: BusOperator
    public var direction: Int
    public var stopSequence: Int
    public var busStopCode: String
    public var distance: Double

    //	// MARK: - Timings (grouped)
    public var weekday: BusTiming?
    public var saturday: BusTiming?
    public var sunday: BusTiming?

    public init(
        id: String,
        serviceNo: String,
        operatorType: BusOperator,
        direction: Int,
        stopSequence: Int,
        busStopCode: String,
        distance: Double,
        weekday: BusTiming?,
        saturday: BusTiming?,
        sunday: BusTiming?
    ) {
        self.id = id
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
}

public extension BusRoutingInfoModel {
    convenience init(from sendable: BusRoutingInfo) {
        self.init(
            id: sendable.id,
            serviceNo: sendable.serviceNo,
            operatorType: sendable.operatorType,
            direction: sendable.direction.rawValue,
            stopSequence: sendable.stopSequence,
            busStopCode: sendable.busStopCode,
            distance: sendable.distance,
            weekday: sendable.weekday,
            saturday: sendable.saturday,
            sunday: sendable.sunday
        )
    }

    func toSendable() -> BusRoutingInfo {
        .init(
            serviceNo: serviceNo,
            operatorType: operatorType,
            direction: .init(rawValue: direction) ?? .none,
            stopSequence: stopSequence,
            busStopCode: busStopCode,
            distance: distance,
            weekday: weekday,
            saturday: saturday,
            sunday: sunday
        )
    }

    func update(from item: BusRoutingInfo) {
        if operatorType != item.operatorType {
            operatorType = item.operatorType
        }
        if direction != item.direction.rawValue {
            direction = item.direction.rawValue
        }
        if stopSequence != item.stopSequence {
            stopSequence = item.stopSequence
        }
        if busStopCode != item.busStopCode {
            busStopCode = item.busStopCode
        }

        if distance != item.distance {
            distance = item.distance
        }
        if weekday != item.weekday {
            weekday = item.weekday
        }
        if saturday != item.saturday {
            saturday = item.saturday
        }
        if sunday != item.sunday {
            sunday = item.sunday
        }
    }
}
