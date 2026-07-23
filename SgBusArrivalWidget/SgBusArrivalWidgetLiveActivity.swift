//  SgBusArrivalWidgetLiveActivity.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI
import WidgetKit
import ActivityKit
import AppIntents

struct SgBusArrivalWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BusArrivalAttributes.self) { context in
            BusArrivalLiveActivityView(state: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ArrivalActivityBadge(
                        model: .init(
                            busNumber: context.state.busNumber,
                            stopCode: context.state.busStopCode,
                            stopName: context.state.stopName,
                            date: context.state.arrivalTime
                        )
                    )
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("\(context.state.busStopCode)")
                        .font(.caption.width(.condensed))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.stopName)
                        .font(.caption.width(.condensed))
                }

                DynamicIslandExpandedRegion(.bottom) {
                    Button("End Activity", intent: EndBusArrivalActivityIntent())
                        .buttonStyle(.borderless)
                }
            } compactLeading: {
                Text(context.state.busNumber)
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .lineLimit(1)
            } compactTrailing: {
                Text(context.state.arrivalTime, style: .timer)
            } minimal: {
                BusNumberText(context.state.busNumber, .headline)
            }
            .contentMargins(.trailing, 32, for: .expanded)
            .contentMargins([.leading, .top, .bottom], 6, for: .compactLeading)
            .contentMargins(.all, 6, for: .minimal)
        }

    }
}

private struct BusArrivalLiveActivityView: View {
    let state: BusArrivalAttributes.ContentState

    var body: some View {
        Label {
            LabeledContent {
                Text(state.stopName)
                    .font(.caption2)
            } label: {
                ArrivalActivityBadge(
                    model: .init(
                        busNumber: state.busNumber,
                        stopCode: state.busStopCode,
                        stopName: state.stopName,
                        date: state.arrivalTime
                    )
                )
            }
        } icon: {
            Image("bus")
                .resizable()
                .scaledToFit()
                .frame(height: 30)
        }
        .padding(.horizontal)
        .lineHeight(.multiple(factor: 1.2))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Bus \(state.busNumber) arriving at \(state.stopName), bus stop \(state.busStopCode)"
        )
    }
}
