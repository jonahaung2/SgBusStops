//  BusStopsViewModel.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Client
import Models
import Combine
import Services
import Foundation

@Observable
final class BusStopsViewModel: ViewModel {

    var displayType: DisplayType = .busStops {
        didSet {
            UserDefaults.standard.set(displayType.rawValue, forKey: "bus_stops_scene_display_type")
        }
    }

    private(set) var searchText: String = .init()
    @ObservationIgnored private var searchPublisher: PassthroughSubject<String, Never> = .init()
    @ObservationIgnored private let cancelBug: CancelBag = .init()
    func search(_ text: String) {
        guard searchText != text else { return }
        searchText = text
        searchPublisher.send(text)
    }

    @ObservationIgnored private var stops: [Stop] = []
    @ObservationIgnored private var busRoutes: [BusRoutes] = []

    var groupedBusStops: [(roadName: String, stops: [Stop])] = []
    var routes: [BusRoutes] = []

    override init() {
        super.init()
        if let rawValue = UserDefaults.standard.string(forKey: "bus_stops_scene_display_type") {
            displayType = .init(rawValue: rawValue) ?? .busStops
        }
        searchPublisher
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] value in
                guard let self else { return }
                DispatchQueue.main.async {
                    if value == self.searchText {
                        self.performSearch(searchText: value)
                    }
                }
            }
            .store(in: cancelBug)
    }

    func task() async {
        searchText = .init()
        do {
            switch displayType {
            case .busStops:
                if stops.isEmpty {
                    stops = try await SwiftDataStore.shared.store.busStopAll()
                }

            case .busses:
                if busRoutes.isEmpty {
                    busRoutes = try await SwiftDataStore.shared.store
                        .routeAll()
                        .busRoutes()
                }
            }
            performSearch(searchText: searchText)
        } catch {
            showError(error)
        }
    }

    func performSearch(searchText: String) {
        switch displayType {
        case .busStops:
            var busStops: [Stop] {
                if searchText.isEmpty {
                    stops
                } else {
                    stops
                        .filter {
                            TextSearch
                                .matches(text: $0.roadName, query: searchText)
                                || TextSearch
                                .matches(text: $0.desc, query: searchText)
                                || $0.busStopCode
                                .contains(searchText)
                        }
                }
            }
            let grouped = Dictionary(grouping: busStops, by: \.roadName)
            groupedBusStops =
                grouped
                    .map { (roadName: $0.key, stops: $0.value.sorted { $0.desc < $1.desc }) }
                    .sorted { $0.roadName < $1.roadName }

        case .busses:
            if searchText.isEmpty {
                routes = busRoutes.sorted { one, two in
                    one.busNumber < two.busNumber
                }
            } else {
                routes =
                    busRoutes
                        .filter {
                            $0.busNumber.contains(searchText)
                        }.sorted { one, two in
                            one.busNumber < two.busNumber
                        }
            }
        }
    }
}
