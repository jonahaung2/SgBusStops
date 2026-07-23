//  ArrivalColumn.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import Anima
import SwiftUI
import UI
import SGToolTip

struct ArrivalColumn: View {
    
    let arrival: BusArrival.Arrival
    let rank: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            switch rank {
            case 1:
                if let seconds = arrival.arrivalSeconds() {
                    if seconds <= 60 {
                        Text("Arriving")
                            .foregroundStyle(
                                .green.mix(with: .primary, by: 0.15)
                            )
                            .font(.title2.weight(.semibold))

                    } else if seconds < -60 {
                        Text("Departed")
                            .foregroundStyle(.red.mix(with: .primary, by: 0.1))
                            .font(.title2.weight(.semibold))
                    } else {
                        Text(
                            timerInterval: Date.now...countdownEndDate,
                            pauseTime: .distantPast,
                            countsDown: true
                        )
                        .font(.title2.weight(.bold))
                    }
                }

            case 2:
                if let minutes = arrival.arrivalMinutes() {
                    Text(
                        "\(minutes)\(Text("m").fontWeight(.regular).fontWidth(.standard))"
                    )
                    .font(.headline.weight(.semibold))
                }

            default:
                if let minutes = arrival.arrivalMinutes() {
                    Text(
                        "\(minutes)\(Text("m").fontWeight(.regular).fontWidth(.standard))"
                    )
                    .font(.subheadline.weight(.medium))
                }
            }

            HStack(alignment: .bottom, spacing: 1) {
                loadIcon
                    .geometryGroup()
                    .sgToolTip(.bottom) {
                        Text("**\(arrival.load?.description ?? "")**\nCurrent bus occupancy / crowding level")
                    }
                Text(typeText ?? " ")
                    .font(.footnote.weight(.medium).width(.condensed))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 1)
                    .allowsHitTesting(false)
                
                if isWheelchairAccessible {
                    Circle()
                        .overlay {
                            Image(systemName: "wheelchair")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .foregroundColor(Color.white)
                        }
                        .frame(width: 13, height: 13)
                        .foregroundStyle(.yellow.mix(with: .primary, by: 0.15))
                        .geometryGroup()
                        .sgToolTip(.bottom) {
                            Text("Bus is wheel-chair accessible")
                        }
                }
                if arrival.monitored {
                    Image(systemName: "clock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .symbolRenderingMode(.multicolor)
                        .foregroundStyle(.secondary)
                        .geometryGroup()
                    
                }
            }
        }
        .lineHeight(.multiple(factor: 1.2))
        .id(rank)
    }
}

extension ArrivalColumn {

    fileprivate var countdownEndDate: Date {
        guard let seconds = arrival.arrivalSeconds(), seconds > 0 else {
            return .now
        }
        return Date(timeInterval: Double(seconds), since: .now)
    }
}

extension ArrivalColumn {

    @ViewBuilder
    fileprivate var loadIcon: some View {
        switch arrival.load {
        case .seatsAvailable:
            HStack(spacing: -4) {
                Image(systemName: "figure.seated.side.right")
                    .iconStyle(
                        height: 12,
                        color: .green.mix(with: .primary, by: 0.1)
                    )
                Image(systemName: "figure.seated.side.right")
                    .iconStyle(
                        height: 13,
                        color: .green.mix(with: .primary, by: 0.1)
                    )
            }
        case .standingAvailable:
            iconPair("figure.wave", height: 15, color: .orange)
        case .limitedStanding:
            HStack(spacing: -2) {
                Image(systemName: "figure.taichi")
                    .iconStyle(height: 15, color: .red)
                Image(systemName: "figure.wave")
                    .iconStyle(height: 15, color: .red)
            }
        case .none:
            EmptyView()
        }
    }

    fileprivate func iconPair(_ name: String, height: CGFloat, color: Color)
        -> some View
    {
        HStack(spacing: -2) {
            Image(systemName: name)
                .iconStyle(height: height, color: color)
            Image(systemName: name)
                .iconStyle(height: height, color: color)
        }
    }

    fileprivate var typeText: String? {
        switch arrival.type {
        case .singleDeck: "Single"
        case .doubleDeck: "Double"
        case .bendy: "Bendy"
        case .none: nil
        }
    }

    @ViewBuilder
    fileprivate var typeImage: some View {
        switch arrival.type {
        case .singleDeck:
            Image("bus_single_deck")
                .resizable()
                .frame(width: 20, height: 10)
        case .doubleDeck:
            Image("bus_double_deck")
                .resizable()
                .frame(width: 20, height: 14)
        case .bendy:
            Image("bus_bendy")
                .resizable()
                .frame(width: 25, height: 10)
        case .none:
            Image("bus_single_deck")
                .resizable()
                .frame(width: 20, height: 14)
        }
    }

    fileprivate var isWheelchairAccessible: Bool {
        arrival.feature == .wheelchairAccessible
    }
}

extension ArrivalColumn {
    fileprivate var font: Font {
        switch rank {
        case 1:
            .title2.weight(.semibold)
        case 2:
            .headline
        default:
            .footnote.weight(.semibold)
        }
    }
}

extension Image {
    fileprivate func iconStyle(height: CGFloat, color: Color) -> some View {
        resizable()
            .scaledToFit()
            .frame(height: height)
            .foregroundStyle(color)
    }
}
