//
//  NearByViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//
import Client
import CoreLocation
import Foundation
import Models
import Services

@Observable
@MainActor
final class NearbyStopsViewModel {
    var nearbyStops: [BusStop] = []
    var location: LocationResult?
    var address: String?
    var isLoading = false
    var errorMessage: String?
    private var loadTask: Task<Void, Never>?
    private let geocoder = SgGeoCoder()
	private let locationEngine: MobilityLocationEngine
	private weak var token: LocationCancellationToken?
    init() {
		let adaptor = CLLocationManagerAdapter.init()
		locationEngine = .init(adapter: adaptor)
	}

    func startLocation() {
		let token = LocationCancellationToken()
        loadTask?.cancel()
		loadTask = Task(priority: .userInitiated) { [weak self] in
			guard let self else { return }
            if Task.isCancelled { return }
            do {
				let location = try await locationEngine.requestProximityLocation(
					token: token
				)
				let address = try await geocoder.createLocationInfo(from: location.clLocation)
				if Task.isCancelled { return }
				Task { @MainActor in
					self.token = token
					self.location = location
					self.address = address
				}
            } catch {
				cancel()
                showError(error.localizedDescription)
            }
        }
    }

    func cancel() {
		token?.cancel()
        loadTask?.cancel()
    }

    func showError(_ error: String) {
		isLoading = false
        errorMessage = error
    }

    func fetchNear(by location: LocationResult, distance: Double) async {
        let fetcher = BusStopFetcher()
        nearbyStops = await fetcher.near(by: location, distance: distance)

        if nearbyStops.isEmpty {
            await refreshNear(by: location, distance: distance)
        }
    }

    func refreshNear(by location: LocationResult, distance: Double) async {
        isLoading = true
		loadTask?.cancel()
		loadTask = Task(priority: .userInitiated) { [weak self] in
			guard let self else { return }
			if Task.isCancelled {
				isLoading = false
				return
			}
			let fetcher = BusStopFetcher()
			do {
				if Task.isCancelled {
					self.isLoading = false
					return
				}
				let nearbyStops = try await fetcher.refreshNear(by: location, distance: distance)
				if Task.isCancelled {
					self.isLoading = false
					return
				}
				Task { @MainActor in
					self.isLoading = false
					self.nearbyStops = nearbyStops
				}
			} catch {
				showError(error.localizedDescription)
			}
		}
    }
}
