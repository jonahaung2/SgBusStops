//
//  LocationPickerMap.swift
//  HomeForYou
//
//  Created by Aung Ko Min on 9/6/24.
//

import MapKit
import SwiftUI

public struct LocationPickerMap: View {
    private var onSelect: (CLLocationCoordinate2D) async -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var position: MapCameraPosition = .userLocation(fallback: .camera(.init(centerCoordinate: .singapore, distance: 1000)))
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var selection: CLLocationCoordinate2D?
    @State private var animation: SgMapAnimation = .init()
    @State private var location: CLLocationCoordinate2D?

    public init(onSelect: @escaping (CLLocationCoordinate2D) -> Void) {
        self.onSelect = onSelect
    }

    public var body: some View {
        Map(position: $position, interactionModes: .all, selection: $selection) {
            if let selection {
                Marker("Selected", systemImage: "star.fill", coordinate: selection)
                    .tag(selection)
            } else {
                if let coordinate {
                    Marker("Select this Location", systemImage: "plus", coordinate: coordinate)
                        .tag(coordinate)
                }
            }
        }
        .onMapCameraChange(frequency: .continuous) { context in
            if location == nil {
                coordinate = context.camera.centerCoordinate
            }
        }
        .mapControls {
            MapCompass()
            MapScaleView()
            MapUserLocationButton()
        }
        .mapCameraKeyframeAnimator(trigger: animation, keyframes: { _ in
            KeyframeTrack(\MapCamera.distance) {
                LinearKeyframe(animation.distance, duration: 1)
            }
            KeyframeTrack(\MapCamera.pitch) {
                LinearKeyframe(animation.pitch, duration: 3)
            }
        })
        .safeAreaInset(edge: .bottom) {
            VStack {
                if let location {
                    Text("\(location.latitude) \(location.longitude)")
                }
                HStack {
                    if location != nil {
                        Button {
                            location = nil
                            animation.distance = 8000
                            animation.pitch = 0
                        } label: {
                            Image(systemName: "trash.fill")
                                .symbolRenderingMode(.multicolor)
                        }
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text("Close")
                        }
                    }
                    Spacer()
                    if let location {
                        Button {
                            Task {
                                await onSelect(location)
                                try await Task.sleep(nanoseconds: 1000)
                                dismiss()
                            }
                        } label: {
                            Text("Apply")
                        }
                    }
                }
            }
            .padding()
        }
        .onChange(of: selection) {
            if let selection {
                setLocation(selection)
            } else {
                animation = .init(.singapore, distance: 8000, pitch: 25)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                animation = .init(.singapore, distance: 5000, pitch: 50)
            }
        }
    }

    @MainActor private func setLocation(_ location: CLLocationCoordinate2D) {
        self.location = location
        animation = .init(location, distance: 3000, pitch: 75)
    }
}
