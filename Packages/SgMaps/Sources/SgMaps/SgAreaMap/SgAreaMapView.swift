//
//  SgAreaMapView.swift
//
//
//  Created by Aung Ko Min on 31/7/24.
//

import MapKit
import SwiftUI

public struct SgAreaMapView: View {
    private let onSelect: (SgArea) -> Void

    @State private var selection: SgArea?
    private let sgAreas: [SgArea]
    @State private var animation: SgMapAnimation = .init()
    @State private var initialAnimationWorkItem: DispatchWorkItem?

    private let region: MKCoordinateRegion
    private let position: MapCameraPosition
    @Environment(\.presentationMode) private var presentationMode

    public init(onSelect: @escaping (SgArea) -> Void) {
        self.onSelect = onSelect
        let areas = SgArea.allCases
        region = MKCoordinateRegion(coordinates: areas.map(\.geometry.centerCoordinate))
        position = .region(region)
        sgAreas = areas
    }

    public var body: some View {
        MapReader { proxy in
            Map(
                initialPosition: position,
                bounds: MapCameraBounds(
                    centerCoordinateBounds: region,
                    minimumDistance: 50000,
                    maximumDistance: 200_000,
                ),
                interactionModes: .all,
            ) {
                ForEach(sgAreas) { area in
                    let isSelected = selection == area
                    switch area.geometry {
                    case let .polygon(region):
                        MapPolyline(coordinates: region.verticies)
                            .stroke(
								isSelected ? Color.orange : Color.secondary,
								lineWidth: isSelected ? 2 : 0.5,
                            )
                    case let .multiPolygon(regions):
                        ForEach(regions, id: \.id) { region in
                            MapPolyline(coordinates: region.verticies)
                                .stroke(
                                    isSelected ? Color.accentColor : Color.secondary,
                                    lineWidth: isSelected ? 2 : 1,
                                )
                        }
                    }
                    Annotation(coordinate: area.geometry.centerCoordinate) {
                        if isSelected {
                            Text(area.name)
                                .font(.headline)
                        }
                    } label: {
                        if !isSelected {
                            Text(area.name)
                        }
                    }
                }
            }
            .onTapGesture { position in
                if let coordinate = proxy.convert(position, from: .local) {
                    let tappedArea = SgArea(coordinate)
                    let nextSelection = selection == tappedArea ? nil : tappedArea
                    selection = nextSelection
                    animation = .init(
                        coordinate,
                        distance: nextSelection == nil ? 200_000 : 50000,
                        pitch: nextSelection == nil ? 0 : 95,
                    )
                } else {
                    selection = nil
                    animation = .init(.singapore, distance: 150_000, pitch: 0)
                }
            }
        }
        .mapStyle(
            .standard(
				elevation: .realistic,
				emphasis: .muted,
                pointsOfInterest: .excludingAll,
                showsTraffic: false,
			)
        )
        .mapControls {
            MapCompass()
            MapScaleView()
            MapUserLocationButton()
			MapPitchToggle()
        }
		.mapControlVisibility(.visible)
        .mapCameraKeyframeAnimator(trigger: animation) { _ in
            KeyframeTrack(\MapCamera.centerCoordinate) {
                LinearKeyframe(animation.coordinate, duration: 0.2)
            }
            KeyframeTrack(\MapCamera.distance) {
                LinearKeyframe(animation.distance, duration: 0.5)
            }
            KeyframeTrack(\MapCamera.pitch) {
                LinearKeyframe(animation.pitch, duration: animation.pitch == 0 ? 0 : 4)
            }
        }
        .onAppear {
            let workItem = DispatchWorkItem {
                animation = .init(distance: 200_000)
            }
            initialAnimationWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: workItem)
        }
        .onDisappear {
            initialAnimationWorkItem?.cancel()
            initialAnimationWorkItem = nil
        }
		.toolbarVisibility(.hidden, for: .tabBar)
    }
}
