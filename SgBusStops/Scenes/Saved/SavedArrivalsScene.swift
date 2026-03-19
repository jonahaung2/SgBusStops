//
//  SavedArrivalsScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 18/3/26.
//

import SwiftUI
import Services
import Models
import UI

struct SavedArrivalsScene: View {

	@State private var viewModel = SavedArrivalViewModel()
	@Environment(\.editMode) private var editMode

    var body: some View {
		List {
			if let errorMessage = viewModel.errorMessage {
				ContentUnavailableView(
					"No saved stops.",
					systemImage: "star.slash",
					description: Text(errorMessage)
				)
			} else if viewModel.items.isEmpty {
				ProgressView().controlSize(.mini)
					.frame(maxWidth: .infinity)
					.frame(height: 100)
					.listRowBackground(Color.clear)
			}
			ForEach(viewModel.items) { model in
				SavedArrivalCell(model: model)
			}.onDelete { indexSet in
				indexSet.forEach { index in
					viewModel.onDelete(index)
				}
			}.onMove { source, destination in
				viewModel.onMove(from: source, to: destination)
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
