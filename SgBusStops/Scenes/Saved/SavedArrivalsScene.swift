//
//  SavedArrivalsScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 18/3/26.
//

import SwiftUI
import Services

struct SavedArrivalsScene: View {

	@State private var viewModel = SavedArrivalViewModel()

    var body: some View {
		List {
			if viewModel.items.isEmpty {
				ContentUnavailableView("No saved stops.", systemImage: "bookmark.slash")
			}
			ForEach(viewModel.items) { model in
				BusServiceArrivalSection(model)
			}
		}
		.repeatingTask {
			await viewModel.task()
		}
    }
}
