//
//  BusStopDetailsViewModel.swift
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
final class BusStopDetailsViewModel {
    let busStop: BusStop
    var arrivalItems = [ArrivalRowViewModel]()
    var errorMessage: String?

    @ObservationIgnored let busArrivalRepository = BusArrivalRepository(
        networkClient: NetworkClient(),
    )
    init(busStop: BusStop) {
        self.busStop = busStop
    }

    func fetchArrivalForBusStop() async {
        errorMessage = nil
        do {
            let arrival = try await busArrivalRepository.fetch(for: busStop.busStopCode)
            let existing = Dictionary(
                uniqueKeysWithValues: arrivalItems.map { ($0.id, $0) },
            )
            arrivalItems = arrival.services.map { service in
                let item = ArrivalItem(busStop: busStop, arrival: service)
                if let model = existing[item.id] {
                    model.update(item: item)
                    return model
                }
                return .init(item: item)
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func startRefreshing() async {
        try? await Task.sleep(for: .seconds(1))
        await fetchArrivalForBusStop()
    }
}
