//
//  BusStopsViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Client
import Foundation
import Models
import Services

@Observable
@MainActor
final class BusStopsViewModel {
	@ObservationIgnored
	var items = [BusStop]() {
		didSet {
			performSearch()
		}
	}
	@ObservationIgnored
	var searchText = String() {
		didSet {
			performSearch()
		}
	}

    var groupedBusStops = [(roadName: String, stops: [BusStop])]()

	private let debouncer = Debouncer()

	func performSearch() {
		Task {
			await debouncer.submit(delay: .seconds(0.5)) { [weak self] in
				guard let self else { return }
				var busStops: [BusStop] {
					if searchText.isEmpty {
						items
					} else {
						items
							.filter {
								TextSearch
									.matches(text: $0.roadName, query: searchText) || TextSearch
									.matches(text: $0.desc, query: searchText)
							}
					}
				}
				let grouped = Dictionary(grouping: busStops, by: \.roadName)
				let results = grouped
					.map { (roadName: $0.key, stops: $0.value.sorted { $0.desc < $1.desc }) }
					.sorted { $0.roadName < $1.roadName }
				Task { @MainActor in
					self.groupedBusStops = results
				}
			}
		}

	}
}
