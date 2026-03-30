//
//  LiveActivityManager.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 29/3/26.
//

import ActivityKit
import Foundation

enum LiveActivityManagerError: LocalizedError, Sendable {
	case activitiesDisabled

	var errorDescription: String? {
		switch self {
		case .activitiesDisabled:
			return "Live Activities are unavailable for this app right now."
		}
	}
}

enum LiveActivityManager {

	nonisolated static func isTracking(busNumber: String, busStopCode: String) -> Bool {
		trackingActivity(busNumber: busNumber, busStopCode: busStopCode) != nil
	}

	nonisolated static func start(model: LiveActivityModel) async throws {
		guard ActivityAuthorizationInfo().areActivitiesEnabled else {
			throw LiveActivityManagerError.activitiesDisabled
		}

		let state = BusArrivalAttributes.ContentState(
			busNumber: model.busNumber, busStopCode: model.stopCode,
			stopName: model.stopName,
			arrivalTime: model.date
		)

		if let activity = trackingActivity(
			busNumber: model.busNumber,
			busStopCode: model.stopCode
		) {
			await activity.update(content(for: state))
			await endNonMatchingActivities(for: state.trackingID)
			return
		}

		await endAll()
		_ = try Activity.request(
			attributes: BusArrivalAttributes(id: state.trackingID),
			content: content(for: state),
			pushType: nil
		)
	}

	nonisolated static func sync(
		busNumber: String,
		busStopCode: String,
		arrivalTime: Date?
	) async {
		guard let activity = trackingActivity(busNumber: busNumber, busStopCode: busStopCode) else {
			return
		}

		guard let arrivalTime else {
			await end(busNumber: busNumber, busStopCode: busStopCode)
			return
		}

		let state = BusArrivalAttributes.ContentState(
			busNumber: activity.content.state.busNumber,
			busStopCode: activity.content.state.busStopCode,
			stopName: activity.content.state.stopName,
			arrivalTime: arrivalTime
		)

		await activity.update(content(for: state))
	}

	nonisolated static func end(busNumber: String, busStopCode: String) async {
		let activitiesToEnd = activities.filter {
			$0.content.state.busNumber == busNumber && $0.content.state.busStopCode == busStopCode
		}

		for activity in activitiesToEnd {
			await activity.end(content(for: activity.content.state), dismissalPolicy: .immediate)
		}
	}

	nonisolated static func endAll() async {
		for activity in activities {
			await activity.end(content(for: activity.content.state), dismissalPolicy: .immediate)
		}
	}

	nonisolated static var activities: [Activity<BusArrivalAttributes>] {
		Activity<BusArrivalAttributes>.activities
	}

	private nonisolated static func trackingActivity(
		busNumber: String,
		busStopCode: String
	) -> Activity<BusArrivalAttributes>? {
		activities.first {
			$0.content.state.busNumber == busNumber && $0.content.state.busStopCode == busStopCode
		}
	}

	private nonisolated static func endNonMatchingActivities(for trackingID: String) async {
		for activity in activities where activity.attributes.id != trackingID {
			await activity.end(content(for: activity.content.state), dismissalPolicy: .immediate)
		}
	}

	private nonisolated static func content(
		for state: BusArrivalAttributes.ContentState
	) -> ActivityContent<BusArrivalAttributes.ContentState> {
		ActivityContent(
			state: state,
			staleDate: max(state.arrivalTime.addingTimeInterval(120), .now.addingTimeInterval(120))
		)
	}
}
