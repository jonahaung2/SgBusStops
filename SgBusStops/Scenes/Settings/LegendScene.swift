//
//  LegendScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 8/9/26.
//

import SwiftUI

struct LegendScene: View {
    var body: some View {
        Form {
            Section("Passenger Load") {
                Label {
                    Text("Seats available")
                } icon: {
                    HStack(spacing: -4) {
                        Image(systemName: "figure.seated.side.right")
                            .iconStyle(
                                height: 24,
                                color: .green.mix(with: .primary, by: 0.1)
                            )
                        Image(systemName: "figure.seated.side.right")
                            .iconStyle(
                                height: 24,
                                color: .green.mix(with: .primary, by: 0.1)
                            )
                    }
                    .frame(width: 24, height: 24)
                }
                Label {
                    Text("Standing available")
                } icon: {
                    iconPair("figure.wave", height: 24, color: .orange)
                        .frame(width: 24, height: 24)
                }
                Label {
                    Text("Limited standing")
                } icon: {
                    HStack(spacing: -2) {
                        Image(systemName: "figure.taichi")
                            .iconStyle(height: 24, color: .red)
                        Image(systemName: "figure.wave")
                            .iconStyle(height: 24, color: .red)
                    }
                    .frame(width: 24, height: 24)
                }
            }
            Section("Arrival Information") {
                Label {
                    Text("Wheelchair accessible")
                } icon: {
                    ZStack {
                        Image(systemName: "circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.yellow.mix(with: .primary, by: 0.15))
                        Image(systemName: "wheelchair")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                    }
                }

                Label {
                    Text("Scheduled arrival time")
                } icon: {
                    Image(systemName: "clock.badge")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .symbolRenderingMode(.multicolor)
                }
            }

            Section("Bus Type") {
                Label {
                    Text("Single-deck bus")
                } icon: {
                    Image(systemName: "bus.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                Label {
                    Text("Double-deck bus")
                } icon: {
                    Image(systemName: "bus.doubledecker.fill")
                        .resizable()
                        .frame(width: 20, height: 28)
                }
                Label {
                    Text("Bendy bus")
                } icon: {
                    Image("bus_single_deck")
                        .resizable()
                        .frame(width: 35, height: 18)
                }
            }
        }
        .navigationTitle("Legend")
    }

    private func iconPair(_ name: String, height: CGFloat, color: Color)
        -> some View
    {
        HStack(spacing: -2) {
            Image(systemName: name)
                .iconStyle(height: height, color: color)
            Image(systemName: name)
                .iconStyle(height: height, color: color)
        }
    }
}

#Preview {
    LegendScene()
}
