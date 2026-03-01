//
//  NearByScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Models
import Services
import SwiftUI
import UI

struct NearByScene: View {
    @State private var viewModel: NearbyStopsViewModel
    @AppStorage("nearbyDistance") private var distance: Double = 1000
    @Environment(\.scenePhase) private var scenePhase

    init() {
        _viewModel = .init(wrappedValue: .init())
    }

    var body: some View {
        VStack {
            if let location = viewModel.location {
                List {
                    Section {
                        if let errorMessage = viewModel.errorMessage {
                            errorView(text: errorMessage)
                        } else {
                            ForEach(viewModel.nearbyStops) { stop in
                                BusStopCell(busStop: stop)
                            }
                        }
                    } header: {
                        VStack(alignment: .center) {
                            if viewModel.nearbyStops.isEmpty, viewModel.isLoading {
                                Text("Please wait while the app updates the bus stop list.")
                                LoadingIndicator(20)
                                    .padding(.top)
                            } else {
                                if let address = viewModel.address {
                                    Text(address)
                                }
                            }
                        }
                        .font(.footnote.italic())
                        .lineHeight(.tight)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
						.unredacted()
                    }
                }
				.redacted(reason: viewModel.isLoading ? [.placeholder] : [])
                .onChange(of: scenePhase) { _, newValue in
                    switch newValue {
                    case .active:
                        viewModel.startLocation()
					case .inactive:
						viewModel.cancel()
                    default:
                        break
                    }
                }
                .onChange(of: location, initial: true) { _, newValue in
                    Task {
                        await viewModel.fetchNear(by: newValue, distance: distance)
                    }
                }
            } else {
                VStack {
                    LoadingIndicator(22)
                }
                .task {
                    viewModel.startLocation()
                }
                .onDisappear {
                    viewModel.cancel()
                }
            }
        }.refreshable {
            if let location = viewModel.location {
                await viewModel.refreshNear(by: location, distance: distance)
            } else {
                viewModel.startLocation()
            }
        }
    }

    private func errorView(text: String) -> some View {
        ContentUnavailableView {
            Label("No bus stop found near you.", systemImage: "signpost.right.and.left.fill")
        } description: {
            Text(text)
        } actions: {
            if let location = viewModel.location {
                Button("Try Once More Again") {
                    Task {
                        await viewModel.fetchNear(by: location, distance: distance)
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonSizing(.flexible)
            } else {
                Button("Try Once More Again") {
                    viewModel.startLocation()
                }
                .buttonStyle(.borderedProminent)
                .buttonSizing(.flexible)
            }
        }
    }
}
