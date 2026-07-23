//  ArrivalActivityBadge.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI

struct ArrivalActivityBadge: View {
    let model: LiveActivityModel
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = context.date
            let seconds = model.date.secondsFromNow

            HStack(alignment: .bottom, spacing: 2) {
                BusNumberText(model.busNumber, .title2)
                switch true {
                case seconds > 60:
                    Text(timerInterval: now ... model.date)
                        .font(.footnote.width(.condensed).weight(.medium))
                case seconds <= -60:
                    Text("Departed")
                        .font(.footnote.width(.condensed).weight(.semibold))
                        .foregroundStyle(.red.gradient)
                default:
                    Text("Arr")
                        .font(.footnote.width(.condensed).weight(.semibold))
                        .foregroundStyle(.green.mix(with: .primary, by: 0.1))
                }
            }
            .lineHeight(.tight)
        }
    }
}
