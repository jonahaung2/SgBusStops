//
//  BusStopDetailsScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Models
import SwiftUI
import UI

struct BusStopDetailsScene: View {
    @State private var viewModel: BusStopDetailsViewModel
    init(_ busStop: BusStop) {
        _viewModel = .init(wrappedValue: .init(busStop: busStop))
    }

    var body: some View {
        List {

            if viewModel.isLoading, !viewModel.hasViewLoaded {
                LoadingIndicator(20)
            } else if let errorMessage = viewModel.errorMessage, viewModel.responses.isEmpty {
                ContentUnavailableView {
                    Label("Unable to Load Arrivals", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Retry") {
                        Task {
                            await viewModel.fetchArrivalForBusStop()
                        }
                    }
                }
            } else if viewModel.responses.isEmpty {
                ContentUnavailableView("No bus arrival yet", systemImage: "bus.fill")
            } else {
				Section {

				} header: {
					VStack(alignment: .trailing, spacing: 4) {
						Text(viewModel.busStop.desc)
							.font(.title2).fontWeight(.semibold)
					}
					.frame(maxWidth: .infinity)
					.foregroundStyle(.primary)
				}
                ForEach(viewModel.responses) { response in
                    Section {
                        BusServicArrivalCell(serviceArrival: response)
                    } header: {
                        HStack(alignment: .lastTextBaseline) {
                            Text(response.serviceNo)
                                .font(.largeTitle.weight(.bold).width(.condensed))
                                .lineHeight(.tight)
                                .foregroundStyle(
                                    AngularGradient(colors: [.indigo, .black, .red], center: .center)
                                        .opacity(0.8),
                                )
                            Spacer()
                            Text(response.operatorCode.rawValue)
                                .font(.footnote.weight(.semibold).smallCaps())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .listSectionSpacing(8)
        .task {
            await viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .refreshable {
            await viewModel.fetchArrivalForBusStop()
        }
        .environment(\.refreshAction, .init(action: handleRefresh))
		.toolbarTitleDisplayMode(.inline)
		.navigationTitle(viewModel.busStop.roadName)
		.navigationSubtitle(viewModel.busStop.busStopCode)
    }

    private func handleRefresh(_ value: String) {
        Task {
            await viewModel.fetchArrivalForBusService(busServiceNumber: value)
        }
    }
}
