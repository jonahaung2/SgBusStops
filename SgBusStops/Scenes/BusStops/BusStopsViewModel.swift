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
    var items = [BusStop]()
    var searchText = String()

    var groupedBusStops: [(roadName: String, stops: [BusStop])] {
        let grouped = Dictionary(grouping: busStops, by: \.roadName)
        return grouped
            .map { (roadName: $0.key, stops: $0.value.sorted { $0.desc < $1.desc }) }
            .sorted { $0.roadName < $1.roadName }
    }

    private var busStops: [BusStop] {
        if searchText.isEmpty {
            items
        } else {
            items
                .filter {
                    $0.roadName
                        .lowercased()
                        .contains(searchText.lowercased()) || $0.desc
                        .lowercased()
                        .contains(searchText.lowercased())
                }
        }
    }

    func fetchAll() async {
        let fetcher = BusStopFetcher()
        do {
            items = try await fetcher.all()
        } catch {
            print(error)
        }
    }

    func refresh() async {
        let fetcher = BusStopFetcher()
        do {
            items = try await fetcher.refreshAll()
        } catch {
            print(error)
        }
    }
}
