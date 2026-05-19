//  LiveActivityBadge.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Pow
import SwiftUI

struct LiveActivityBadge: View {

    let model: LiveActivityModel
    @Environment(LiveActivityViewModel.self) private var liveActivity
    private var isTracking: Bool {
        liveActivity.current?.stopCode == model.stopCode
            && liveActivity.current?.busNumber == model.busNumber
    }

    var body: some View {
        Image(systemName: isTracking ? "circlebadge.fill" : "bell.badge.fill")
            .symbolRenderingMode(.hierarchical)
            .imageScale(.small)
            .foregroundStyle(
                isTracking ? Color.pink.gradient : Color.secondary.gradient
            )
            ._onButtonGesture { _ in

            } perform: {
                Task {
                    if isTracking {
                        await liveActivity.endAll()
                    } else {
                        await liveActivity.start(model: model)
                    }
                }
            }
            .conditionalEffect(
                .repeat(
                    .pulse(
                        shape: .ellipse,
                        style: .red.gradient,
                        drawingMode: .fill,
                        count: 3
                    ),
                    every: .seconds(2)
                ),
                condition: isTracking
            )
            .changeEffect(.jump(height: 25), value: isTracking, isEnabled: isTracking)
            .changeEffect(.feedbackHapticSelection, value: isTracking)
            .accessibilityLabel(
                isTracking ? "Stop Live Activity" : "Start Live Activity"
            )
    }
}
