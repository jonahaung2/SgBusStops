//
//  BussesScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 25/3/26.
//

import SwiftUI
import Models
import SgMaps
internal import _LocationEssentials

struct StopBussesScene: View {

	@State private var viewModel: StopBussesSceneViewModel

	init(_ stop: Stop) {
		_viewModel = .init(wrappedValue: .init(stop))
	}
	
    var body: some View {
		List {
			Section {
				ForEach(viewModel.busRoutes) { busRoute in
					StopBusRouteCell(stop: viewModel.stop, busRoute: busRoute)
				}
			} header: {
				Text("Available Services")
					.font(.subheadline.weight(.regular))

			}
		}
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				NavigationLink {
					AnimatedMap(items: [viewModel.stop.mapItem]) { item in
						item.location.coordinate
					} title: { value in
						value.name
					}
				} label: {
					Image(systemName: "mappin.and.ellipse")
				}
			}
		}
		.task {
			await viewModel.task()
		}
		.toolbarTitleDisplayMode(.large)
		.navigationTitle(viewModel.stop.roadName)
		.navigationSubtitle(viewModel.stop.desc)
		.task {
			await viewModel.task()
		}
    }
}
