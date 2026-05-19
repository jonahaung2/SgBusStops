//
//  FavouriteArrivalsScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 18/3/26.
//

import Models
import Services
import SwiftUI
import UI

struct FavouriteArrivalsScene: View {

	@State private var viewModel = FavouriteArrivalViewModel()
	@State private var isEditing = false
	@AppStorage("arrival_refresh_interval") private var arrivalRefreshInterval: Double = 20
	@Environment(LiveActivityViewModel.self) private var liveActivity
	private func model(for favourite: FavouriteArrival) -> ArrivalRowViewModel? {
        if let matched = viewModel.items.first(where: { item in
			let stopCodeMatches = item.arrival.busStopCode == favourite.busStopCode
			let serviceMatches = item.arrival.bus.busNumber == favourite.busServiceNumber
            return stopCodeMatches && serviceMatches
        }) {
            return matched
        }
        return nil
    }


	var body: some View {
		List {
            if let error = viewModel.error {
                ContentUnavailableView {
                    Label(error.title, systemImage: error.imageName)
                } description: {
                    Text(error.description)
                }
            }

			if isEditing {
				ForEach(viewModel.favourites) { favourite in
					VStack {
						if let matched = model(for: favourite) {
							if isEditing {
								VStack {
									FavouriteArrivalCell(model: matched)
								}
							} else {
								FavouriteArrivalCell(model: matched)
							}
						} else {
							FavouriteCell(item: favourite)
						}
					}
				}
				.onDelete { indexSet in
					for index in indexSet {
						viewModel.onDelete(index)
					}
				}
				.onMove { source, destination in
					viewModel.onMove(from: source, to: destination)
				}
			} else {
				ForEach(viewModel.favourites) { favourite in
					if let matched = model(for: favourite) {
						if isEditing {
							VStack {
								FavouriteArrivalCell(model: matched)
							}
						} else {
							FavouriteArrivalCell(model: matched)
						}
					} else {
						FavouriteCell(item: favourite)
					}
				}
				.onDelete { indexSet in
					for index in indexSet {
						viewModel.onDelete(index)
					}
				}
			}
		}
		.environment(\.editMode, .constant(isEditing ? .active : .inactive))
		.overlay {
			if viewModel.isLoading {
				ProgressView().controlSize(.mini)
					.frame(maxWidth: .infinity)
					.frame(height: 100)
					.listRowBackground(Color.clear)
			}
		}
		.toolbar {
			ToolbarItem {
				Button {
					isEditing.toggle()
				} label: {
					Text(isEditing ? "Done" : "Edit")
				}
			}
		}
		.repeatingTask(every: .seconds(arrivalRefreshInterval)) {
			await viewModel.task()
		}
		.refreshable {
			await viewModel.task()
		}
	}
}
