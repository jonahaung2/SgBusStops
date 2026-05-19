//  BusStopSpinningMap.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI
import CoreLocation

struct BusStopSpinningMap: View {
    var location: CLLocation
    var topSafeAreaInset: Double
    var animated = true

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(paused: !animated)) { context in
                let seconds = context.date.timeIntervalSince1970
                let rotationPeriod = 120.0
                let headingDelta = seconds.percent(truncation: rotationPeriod)
                let pitchPeriod = 30.0
                let pitchDelta = seconds
                    .percent(truncation: pitchPeriod)
                    .symmetricEaseInOut()

                let viewWidthPercent = (350.0 ... 1000).percent(for: proxy.size.width)
                let distanceMultiplier = (1 - viewWidthPercent) * 0.5 + 1

                DetailedMapView(
                    location: location,
                    distance: distanceMultiplier * (200 ... 500).value(percent: 1 - pitchDelta),
                    pitch: (30 ... 80).value(percent: pitchDelta),
                    heading: 360 * headingDelta,
                    topSafeAreaInset: topSafeAreaInset
                )
            }
        }.mask {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.05),
                    .init(color: .black, location: 0.95),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.05),
                    .init(color: .black, location: 0.95),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

import SwiftUI
internal import MapKit

private typealias ViewControllerRepresentable = UIViewControllerRepresentable

struct DetailedMapView: ViewControllerRepresentable {
    typealias ViewController = UIViewController

    var location: CLLocation
    var distance: Double = 1000
    var pitch: Double = 0
    var heading: Double = 0
    var topSafeAreaInset: Double

    final class Controller: ViewController {
        var mapView: MKMapView {
            guard let tempView = view as? MKMapView else {
                fatalError("View could not be cast as MapView.")
            }
            return tempView
        }

        override func loadView() {
            let mapView = MKMapView()
            view = mapView
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            let configuration = MKStandardMapConfiguration(
                elevationStyle: .realistic,
                emphasisStyle: .default
            )
            configuration.pointOfInterestFilter = .includingAll
            configuration.showsTraffic = false
            mapView.preferredConfiguration = configuration
            mapView.isZoomEnabled = false
            mapView.isPitchEnabled = false
            mapView.isScrollEnabled = false
            mapView.isRotateEnabled = false
            mapView.showsCompass = false
        }
    }

    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ controller: Controller, context: Context) {
        update(controller: controller)
    }

    func update(controller: Controller) {
        controller.mapView.pointOfInterestFilter = pitch > 60 ? .excludingAll : .includingAll
        controller.mapView.camera = MKMapCamera(
            lookingAtCenter: location.coordinate,
            fromDistance: distance,
            pitch: pitch,
            heading: heading
        )
    }
}
