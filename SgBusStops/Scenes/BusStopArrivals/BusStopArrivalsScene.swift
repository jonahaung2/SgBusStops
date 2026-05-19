//  BusStopArrivalsScene.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import UI
import Pow
import Models
import SgMaps
import SwiftUI
import Services
internal import _LocationEssentials

struct BusStopArrivalsScene: View {

    @State private var viewModel: BusStopArrivalsViewModel
    @Environment(BusStore.self) private var store
    @AppStorage("show_map_at_bus_stop_arrival") private var showMapAtBusStopArrival = true
    @AppStorage("arrival_refresh_interval") private var arrivalRefreshInterval: Double = 20

    private var busStop: Stop? { store.busStop(for: viewModel.busStopCode) }
    @State
    private var isEnabled: Bool = false
    init(_ busStopCode: String) {
        _viewModel = .init(wrappedValue: .init(busStopCode: busStopCode))
    }

    var body: some View {
        List {
            if showMapAtBusStopArrival {
                if let bus = store.busStop(for: viewModel.busStopCode) {
                    ZStack {
                        Color.clear.frame(height: 350)
                            .hidden()
                        Image(systemName: "circlebadge.fill")
                            .foregroundStyle(Color.red.gradient)
                            .conditionalEffect(
                                .repeat(
                                    .pulse(
                                        shape: .circle,
                                        style: .pink,
                                        drawingMode: .stroke,
                                        count: 3
                                    ),
                                    every: .seconds(2)
                                ),
                                condition: isEnabled
                            ).imageScale(.small)
                    }
                    .background(alignment: .bottom) {
                        BusStopSpinningMap(location: bus.location, topSafeAreaInset: 0)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())
                }
            }

            if let errorMessage = viewModel.error {
                Section {
                    ContentUnavailableView {
                        Label(errorMessage.title, systemImage: errorMessage.imageName)
                    } description: {
                        Text(errorMessage.description)
                    } actions: {
                        Button("Retry") {
                            Task {
                                await viewModel.fetchArrivalForBusStop()
                            }
                        }
                    }
                }
            } else {

                ForEach(viewModel.arrivalItems) {
                    BusStopArrivalSection($0)
                }

                if !viewModel.isLoading {
                    let excluded = viewModel.serviceRoutes.filter { item in
                        if viewModel.arrivalItems
                            .contains(
                                where: {
                                    $0.arrival.arrival.serviceNo == item.busNumber
                                }
                            )
                        {
                            return false
                        }
                        return true
                    }
                    if excluded.isEmpty == false {
                        Section {
                            VStack(spacing: 8) {
                                Text("Not currently serving")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                FlowLayout(alignment: .center, spacing: 16) {
                                    ForEach(excluded) { route in
                                        BusNumberText(route.busNumber, .title3)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }.overlay {
            if viewModel.isLoading {
                ProgressView().controlSize(.mini)
            }
        }
        .autotoggle($isEnabled)
        .toolbar {
            if !showMapAtBusStopArrival, let busStop {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        AnimatedMap(items: [busStop.mapItem]) { item in
                            item.location.coordinate
                        } title: { value in
                            value.name
                        }
                    } label: {
                        Image(systemName: "mappin.and.ellipse")
                    }
                }
            }

        }
        .repeatingTask(every: .seconds(arrivalRefreshInterval)) {
            await viewModel.fetchArrivalForBusStop()
        }
        .refreshable {
            await viewModel.fetchArrivalForBusStop()
        }
        .toolbarTitleDisplayMode(.large)
        .navigationTitle(busStop?.roadName ?? "")
        .navigationSubtitle(busStop?.desc ?? "")
    }

}

extension View {
    func autotoggle(_ binding: Binding<Bool>, with animation: Animation = .default) -> some View {
        onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(animation) {
                    binding.wrappedValue = true
                }
            }
        }
    }
}
