//
//  LiveMapView.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 23/2/26.
//

import SwiftUI
internal import MapKit

public struct LiveMapView<AnnotationView: View>: View {
    @Binding private var annotations: [MapAnnotationItem]
    @State private var position: MapCameraPosition

    private let annotationView: (MapAnnotationItem) -> AnnotationView

    init(
        region: MKCoordinateRegion,
        annotations: Binding<[MapAnnotationItem]>,
        @ViewBuilder annotationView: @escaping (MapAnnotationItem) -> AnnotationView,
    ) {
        _annotations = annotations
        _position = State(initialValue: .userLocation(fallback: .region(region)))
        self.annotationView = annotationView
    }

    public var body: some View {
        Map(position: $position) {
            ForEach(annotations) { item in
                Annotation(
                    item.title,
                    coordinate: item.coordinate,
                ) {
                    annotationView(item)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .onAppear {
            focusOnFirstAnnotation()
        }
        .onChange(of: annotations) { _, _ in
            focusOnFirstAnnotation()
        }
    }

    private func focusOnFirstAnnotation() {
        guard let item = annotations.first else {
            return
        }
        withAnimation(.smooth(duration: 0.3)) {
            position = .camera(
                .init(
                    centerCoordinate: item.coordinate,
                    distance: 450,
                    heading: 0,
                    pitch: 45,
                ),
            )
        }
    }
}
