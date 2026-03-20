//
//  SavedArrivalsScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 18/3/26.
//

import Models
import Services
import SwiftUI
import UI

struct SavedArrivalsScene: View {
    @State private var viewModel = SavedArrivalViewModel()
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
            ForEach(viewModel.items) { model in
                SavedArrivalCell(model: model)
            }.onDelete { indexSet in
                for index in indexSet {
                    viewModel.onDelete(index)
                }
            }.onMove { source, destination in
                viewModel.onMove(from: source, to: destination)
            }
		}.overlay {
			if viewModel.items.isEmpty {
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
