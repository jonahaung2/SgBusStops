//  AnimatedMap.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import MapKit
import SwiftUI
import Combine

public struct AnimatedMap<Item: Identifiable & Equatable>: View {

    private let items: [Item]
    private let coordinate: (Item) -> CLLocationCoordinate2D
    private let title: (Item) -> String
    private let interval: TimeInterval

    @State private var tick: Int = 0
    @State private var focusedItem: Item?
    @State private var selection: MKMapItem?

    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    public init(
        items: [Item],
        initialFocus: Item? = nil,
        interval: TimeInterval = 1,
        coordinate: @escaping (Item) -> CLLocationCoordinate2D,
        title: @escaping (Item) -> String
    ) {
        self.items = items
        self.coordinate = coordinate
        self.title = title
        self.interval = max(0.3, interval)

        _focusedItem = State(initialValue: initialFocus ?? items.first)

        timer = Timer.publish(
            every: self.interval,
            on: .main,
            in: .common
        ).autoconnect()
    }

    public var body: some View {
        Map(initialPosition: cameraPosition, selection: $selection) {
            ForEach(items) { item in
                let mapItem = makeMKMapItem(for: item)

                Marker(title(item), coordinate: coordinate(item))
                    .tint(item == focusedItem ? .red : .blue)
                    .tag(mapItem)
            }
        }
        .mapStyle(
            .standard(
                elevation: .realistic,
                emphasis: .automatic,
                pointsOfInterest: [
                    .publicTransport,
                    .landmark, .foodMarket
                ],
                showsTraffic: false
            )
        )
        .mapCameraKeyframeAnimator(trigger: tick) { camera in

            let progress = normalizedProgress
            let target = coordinate(focusedItem ?? items.first!)

            KeyframeTrack(\MapCamera.centerCoordinate) {
                LinearKeyframe(
                    interpolateCoordinate(
                        from: camera.centerCoordinate,
                        to: target,
                        t: progress
                    ),
                    duration: interval
                )
            }

            KeyframeTrack(\MapCamera.distance) {
                LinearKeyframe(
                    zoomDistance(progress),
                    duration: interval
                )
            }

            KeyframeTrack(\MapCamera.pitch) {
                LinearKeyframe(
                    tilt(progress),
                    duration: interval
                )
            }

            KeyframeTrack(\MapCamera.heading) {
                LinearKeyframe(
                    camera.heading + rotationPerTick,
                    duration: interval
                )
            }
        }
        .onReceive(timer) { _ in
            handleTick()
        }
        .onChange(of: selection) { _, newValue in
            syncSelection(newValue)
        }
        .mapItemDetailSheet(item: $selection)
    }
}

//
// MARK: - Camera
//
private extension AnimatedMap {

    var cameraPosition: MapCameraPosition {
        guard let focusedItem else { return .automatic }

        return .camera(
            MapCamera(
                centerCoordinate: coordinate(focusedItem),
                distance: Constants.baseDistance,
                pitch: Constants.basePitch
            )
        )
    }
}

//
// MARK: - Tick
//
private extension AnimatedMap {

    func handleTick() {
        tick += 1

        guard items.count > 1 else { return }

        if tick % Constants.cycleTicks(interval) == 0 {
            focusedItem = nextItem()
            selection = focusedItem.map { makeMKMapItem(for: $0) }
        }
    }

    func nextItem() -> Item? {
        items
            .filter { $0.id != focusedItem?.id }
            .randomElement()
    }

    var normalizedProgress: Double {
        Double(tick % Constants.period) / Double(Constants.period)
    }

    var rotationPerTick: Double {
        360 / Double(Constants.period)
    }
}

//
// MARK: - Selection Sync
//
private extension AnimatedMap {

    func syncSelection(_ mapItem: MKMapItem?) {
        guard let mapItem else { return }

        if let matched = items.first(where: {
            coordinate($0).latitude == mapItem.placemark.coordinate.latitude &&
                coordinate($0).longitude == mapItem.placemark.coordinate.longitude
        }) {
            if matched != focusedItem {
                focusedItem = matched
                tick += 1 // trigger fly-to immediately
            }
        }
    }
}

//
// MARK: - Helpers
//
private extension AnimatedMap {

    func makeMKMapItem(for item: Item) -> MKMapItem {
        MKMapItem(
            placemark: MKPlacemark(coordinate: coordinate(item))
        )
    }

    func interpolateCoordinate(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D,
        t: Double
    ) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: lerp(from.latitude, to.latitude, t),
            longitude: lerp(from.longitude, to.longitude, t)
        )
    }

    func zoomDistance(_ t: Double) -> Double {
        if t < 0.5 {
            lerp(Constants.baseDistance, Constants.flyOutDistance, t * 2)
        } else {
            lerp(Constants.flyOutDistance, Constants.baseDistance, (t - 0.5) * 2)
        }
    }

    func tilt(_ t: Double) -> Double {
        lerp(Constants.basePitch, Constants.flyPitch, sin(t * .pi))
    }

    func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
        a + (b - a) * (t * t * (3 - 2 * t))
    }
}

//
// MARK: - Constants
//
private enum Constants {
    static let baseDistance: Double = 500
    static let flyOutDistance: Double = 1200

    static let basePitch: Double = 45
    static let flyPitch: Double = 70

    static let period: Int = 60

    static func cycleTicks(_ interval: TimeInterval) -> Int {
        Int(60 / interval)
    }
}
