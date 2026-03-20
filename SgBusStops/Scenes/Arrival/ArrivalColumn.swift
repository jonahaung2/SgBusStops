//
//  ArrivalColumn.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 20/3/26.
//

import SwiftUI
import Models
import UI

struct ArrivalColumn: View {
	let arrival: BusArrival
	let rank: Int

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			timeView
				.font(font)
			metaView
		}
		.lineHeight(.multiple(factor: 1.2))
	}
}

private extension ArrivalColumn {
	@ViewBuilder
	var timeView: some View {
		if rank == 1, let endDate = countdownEndDate {
			Text(
				timerInterval: Date.now ... endDate,
				pauseTime: .distantPast,
				countsDown: true,
			)
		} else {
			arrivalText
		}
	}

	var countdownEndDate: Date? {
		guard let seconds = arrival.arrivalSeconds(), seconds > 0 else {
			return nil
		}
		return Date(timeInterval: Double(seconds), since: .now)
	}

	@ViewBuilder
	var arrivalText: some View {
		if let seconds = arrival.arrivalSeconds(now: .now) {
			switch seconds {
			case ..<(-60):
				Text("Departed").foregroundStyle(.red)
			case ..<30:
				Text("Arriving")
					.fontWidth(.condensed)
					.foregroundStyle(.green.mix(with: .primary, by: 0.1))
			case ..<60:
				Text("\(seconds)\(Text("s").font(.caption2))")
			default:
				Text("\(seconds / 60)\(Text("m").font(.caption2))")
			}
		} else {
			Text("N.A").foregroundStyle(.secondary)
		}
	}
}

private extension ArrivalColumn {
	var metaView: some View {
		HStack(spacing: 4) {
			loadIcon
			Text(typeText ?? "NA")
				.font(.footnote.weight(.medium).width(.condensed))
				.foregroundStyle(.secondary)

			if isWheelchairAccessible {
				Image(systemName: "wheelchair")
					.font(.caption2)
					.foregroundStyle(.yellow.mix(with: .primary, by: 0.15))
			}
		}
	}

	@ViewBuilder
	var loadIcon: some View {
		switch arrival.load {
		case .seatsAvailable:
			HStack(spacing: -4) {
				Image(systemName: "figure.seated.side.right")
					.iconStyle(height: 12, color: .green.mix(with: .primary, by: 0.1))
				Image(systemName: "figure.seated.side.right")
					.iconStyle(height: 13, color: .green.mix(with: .primary, by: 0.1))
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

	func iconPair(_ name: String, height: CGFloat, color: Color) -> some View {
		HStack(spacing: -2) {
			Image(systemName: name)
				.iconStyle(height: height, color: color)
			Image(systemName: name)
				.iconStyle(height: height, color: color)
		}
	}

	var typeText: String? {
		switch arrival.type {
		case .singleDeck: "Single"
		case .doubleDeck: "Double"
		case .bendy: "Bendy"
		case .none: nil
		}
	}

	var isWheelchairAccessible: Bool {
		arrival.feature == .wheelchairAccessible
	}
}
private extension ArrivalColumn {
	var font: Font {
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
private extension Image {
	func iconStyle(height: CGFloat, color: Color) -> some View {
		resizable()
			.scaledToFit()
			.frame(height: height)
			.foregroundStyle(color)
	}
}
