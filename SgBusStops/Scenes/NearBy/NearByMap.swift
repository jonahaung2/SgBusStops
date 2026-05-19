//  NearByMap.swift
//
//  Copyright © 2026 Aung Ko Min.
//

internal import MapKit
import UI
import Models
import SwiftUI
import Services

struct NearByMap: View {
    let nearbyStops: [Stop]
    var userLocation: CLLocationCoordinate2D

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selection: MKMapItem?

    private var initialRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: userLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Map(position: $cameraPosition, interactionModes: .all, selection: $selection) {
                UserAnnotation()
                ForEach(nearbyStops, id: \.id) { stop in
                    let title = stop.desc
                    Marker(
                        title,
                        coordinate: .init(latitude: stop.latitude, longitude: stop.longitude)
                    )
                }
            }
            .mapStyle(.standard(elevation: .realistic, emphasis: .automatic, showsTraffic: false))
            .mapItemDetailSheet(item: $selection, displaysMap: true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .statusBarHidden(true)
        .toolbarVisibility(.hidden, for: .tabBar)
        .task {
            cameraPosition = .region(initialRegion)
            updateCamera()
            try? await Task.sleep(until: .now + Duration.seconds(1))
            updateRegion()
        }
        .onChange(of: nearbyStops) { _, _ in
            updateCamera()
        }
        .onChange(of: userLocation.latitude) { _, _ in
            updateCamera()
        }
        .onChange(of: userLocation.longitude) { _, _ in
            updateCamera()
        }
    }

    private func fittedRegion() -> MKCoordinateRegion? {
        // Collect coordinates: user + stops
        var coords: [CLLocationCoordinate2D] = [userLocation]
        coords
            .append(
                contentsOf:
                nearbyStops
                    .map {
                        CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                    }
            )
        guard !coords.isEmpty else { return nil }

        let lats = coords.map(\.latitude)
        let lons = coords.map(\.longitude)
        guard let minLat = lats.min(), let maxLat = lats.max(), let minLon = lons.min(),
              let maxLon = lons.max() else {
            return nil
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2.0,
            longitude: (minLon + maxLon) / 2.0
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.005, (maxLat - minLat) * 1.6),
            longitudeDelta: max(0.005, (maxLon - minLon) * 1.6)
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    private func updateRegion() {
        var camera = MapCamera(centerCoordinate: userLocation, distance: 1000)
        camera.pitch = 60
        camera.heading = 270
        withAnimation(.interpolatingSpring(duration: 2)) {
            cameraPosition = .camera(camera)
        }
    }

    private func updateCamera() {
        let region = fittedRegion() ?? initialRegion
        withAnimation(.smooth(duration: 0.28)) {
            cameraPosition = .region(region)
        }
    }
}
