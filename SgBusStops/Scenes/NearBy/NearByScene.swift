//  NearByScene.swift
//
//  Copyright © 2026 Aung Ko Min.
import Models
import Charts
import Services
import SgMaps
import SwiftUI
import UI
internal import _LocationEssentials

struct NearByScene: View {

    @State private var viewModel: NearbyStopsViewModel = .init()
    @AppStorage("nearbyDistance") private var distance: Double = 1000
    @Environment(LocationService.self) private var locationService
    @Environment(NavRouter.self) private var navRouter
    @Environment(LiveActivityViewModel.self) private var liveActivity

    @State private var controller: LocationAuthorizationController = .init()

    var body: some View {
        List {
            if controller.phase != .authorized {
                Section("Permission") {
                    LocationCheckerContentUnavailableView()
                }
            } else {
                
                Section {
                    if let error = viewModel.error {
                        ContentUnavailableView {
                            Label(error.title, systemImage: error.imageName)
                        } description: {
                            Text(error.description)
                        }
                    }

                    ForEach(viewModel.nearbyStops) { stop in
                        BusStopCell(busStop: stop) { selection in
                            navRouter.push(.stopArrivals(selection.busStopCode))
                        }
                    }
                } header: {
                    if let address = locationService.address {
                        VStack(alignment: .center) {
                            Text(address)
                        }
                        .font(.footnote.italic())
                        .lineHeight(.tight)
                    }
                } footer: {
                    if !viewModel.nearbyStops.isEmpty {
                        Text("\(distance, specifier: "%.0f" )m")
                            .font(.caption2)
                    }
                }
                
                if !chartEntries.isEmpty {
                    Section {
                        Chart(chartEntries) { entry in
                            BarMark(
                                x: .value("Distance", entry.distance),
                                y: .value("Bus Stop", entry.label)
                            )
                            .clipShape(.rect(cornerRadius: 8))
                            .annotation(position: .trailing, alignment: .leading) {
                                Text(entry.distanceText)
                                    .font(.caption2.smallCaps())
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .chartXAxis {
                            AxisMarks(position: .bottom) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel {
                                    if let distance = value.as(Double.self) {
                                        Text(distanceLabel(for: distance))
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(minHeight: chartHeight)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.all, 8)
                    }
                }
            }
        }
        .animation(.interactiveSpring, value: locationService.address)
        .toolbar {
            if !viewModel.nearbyStops.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        AnimatedMap(items: viewModel.nearbyStops.map(\.mapItem)) { item in
                            item.location.coordinate
                        } title: { value in
                            value.name
                        }
                    } label: {
                        Image(systemName: "mappin.and.ellipse")
                    }
                }
            }
            if let model = liveActivity.current {
                ToolbarItem(placement: .principal) {
                    ArrivalActivityBadge(model: model)
                }
            }
        }
        .task(id: locationService.location) {
            if let location = locationService.location {
                await viewModel.fetchNearby(location: location, distance: distance)
            }
        }
        .refreshable {
            await locationService.startLocation()
        }
    }
}

private extension NearByScene {
    var chartEntries: [NearbyDistanceChartEntry] {
        guard let location = locationService.location else {
            return []
        }
        return viewModel.nearbyStops.prefix(8).map {
            NearbyDistanceChartEntry(stop: $0, location: location)
        }
    }

    var chartHeight: CGFloat {
        CGFloat(chartEntries.count) * 40 + 24
    }

    func distanceLabel(for distance: Double) -> String {
        "\(Int(distance.rounded()))m"
    }
}

private struct NearbyDistanceChartEntry: Identifiable {
    let stop: Stop
    let distance: Double

    init(stop: Stop, location: LocationResult) {
        self.stop = stop
        distance = stop.distance(from: location.coordinate) * 1000
    }

    var id: String {
        stop.id
    }

    var label: String {
        stop.desc
    }

    var distanceText: String {
        "\(Int(distance.rounded())) m"
    }
}
