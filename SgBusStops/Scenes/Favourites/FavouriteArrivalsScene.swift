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
	@Environment(\.editMode) private var editMode

	var body: some View {
		List {
			if let error = viewModel.error {
				ContentUnavailableView {
					Label(error.title, systemImage: error.imageName)
				} description: {
					Text(error.description)
				}
			}
			if editMode?.wrappedValue.isEditing == true {
				ForEach(viewModel.favourites) { favourite in
					if let model = viewModel.items.first(
						where: {
							$0.item.busStop.busStopCode == favourite.busStopCode
							&& $0.item.arrival.serviceNo == favourite.busServiceNumber
						}) {
						VStack {
							FavouriteArrivalCell(model: model)
						}
					} else {
						FavouriteCell(item: favourite)
					}
				}.onDelete { indexSet in
					for index in indexSet {
						viewModel.onDelete(index)
					}
				}
				.onMove { source, destination in
					viewModel.onMove(from: source, to: destination)
				}
			} else {
				ForEach(viewModel.favourites) { favourite in
					if let model = viewModel.items.first(
						where: {
							$0.item.busStop.busStopCode == favourite.busStopCode
							&& $0.item.arrival.serviceNo == favourite.busServiceNumber
						}) {
						FavouriteArrivalCell(model: model)
					} else {
						FavouriteCell(item: favourite)
					}
				}.onDelete { indexSet in
					for index in indexSet {
						viewModel.onDelete(index)
					}
				}
			}
		}
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
				EditButton()
			}
		}
		.repeatingTask {
			await viewModel.task()
		}
		.refreshable {
			await viewModel.task()
		}
	}
}
