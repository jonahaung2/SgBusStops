//  SgMrtMapView.swift
//
//  Copyright © 2024 Aung Ko Min.
//

import MapKit
import SwiftUI

public struct SgMrtMapView: View {
    private let onSelect: (MRT) -> Void
    private let lines: [MRTLine] = MRTLine.allCases
    @State private var selectedLine: MRTLine?
    @State private var selection: MRT?
    @State private var animation: SgMapAnimation
    @State private var touchedPoint: CLLocationCoordinate2D = .singapore
    @Environment(\.dismiss) private var dismiss

    public init(_ onSelect: @escaping (MRT) -> Void) {
        self.onSelect = onSelect
        animation = .init()
    }

    public var body: some View {
        MapReader { proxy in
            Map(selection: $selection) {
                if let selectedLine {
                    ForEach(lines) { line in
                        if line == selectedLine {
                            MapPolyline(coordinates: line.coordinates, contourStyle: .geodesic)
                                .stroke(line.color.gradient, style: StrokeStyle(lineWidth: 5))
                            ForEach(line.mrts) { mrt in
                                if let mainSymbol = mrt.mainSymbol(for: line) {
                                    Marker(mrt.name + "\n\(mainSymbol.code)", monogram: Text(mrt.name.prefix(4)).fontWidth(.condensed), coordinate: mrt.coordinate)
                                        .tint(mainSymbol.swiftColor.gradient)
                                        .tag(mrt)

                                    ForEach(mrt.symbol) { symbol in
                                        if symbol.code != mainSymbol.code {
                                            Annotation(symbol.code, coordinate: mrt.coordinate) {
                                                Circle()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundStyle(symbol.swiftColor.gradient)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    ForEach(lines) { line in
                        MapPolyline(coordinates: line.coordinates, contourStyle: .geodesic)
                            .stroke(line.color.gradient, style: StrokeStyle(lineWidth: selectedLine == line ? 5 : 3, lineCap: .round, lineJoin: .round))
                    }
                }
            }
            .onTapGesture { position in
                if let coordinate = proxy.convert(position, from: .local) {
                    touchedPoint = coordinate

                    if let nearest = closestMRT(from: .init(latitude: coordinate.latitude, longitude: coordinate.longitude), mrts: selectedLine?.mrts ?? MRT.allValues) {
                        if selection == nil, nearest.1 <= 10 {
                            let service = lines.first(where: { $0.mrts.contains { element in
                                element.name == nearest.0.name
                            } })
                            selectedLine = service
                            animation.pitch = 0.7
                            animation.coordinate = coordinate
                        } else {
                            if selection == nil {
                                selectedLine = nil
                            }
                        }
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
        .mapCameraKeyframeAnimator(trigger: animation) { _ in
            KeyframeTrack(\MapCamera.centerCoordinate) {
                LinearKeyframe(selection?.coordinate ?? touchedPoint, duration: 0.3)
            }
            KeyframeTrack(\MapCamera.distance) {
                LinearKeyframe(animation.distance, duration: 1)
            }
            KeyframeTrack(\MapCamera.pitch) {
                LinearKeyframe(animation.pitch, duration: 1)
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
    }

    private func closestMRT(from location: CLLocation, mrts: [MRT]) -> (MRT, Int)? {
        var closestMRT: MRT?
        var smallestDistance: CLLocationDistance?
        for mrt in mrts {
            let mrtLocation = CLLocation(latitude: mrt.latitude, longitude: mrt.longitude)
            let distance = location.distance(from: mrtLocation)

            if smallestDistance == nil || distance < smallestDistance ?? .init() {
                closestMRT = mrt
                smallestDistance = distance
            }
        }
        if let closestMRT, let smallestDistance {
            return (closestMRT, smallestDistance.exponent)
        }
        return nil
    }
}

private extension MRT {
    var asMapItem: MKMapItem {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = name
        return item
    }
}
