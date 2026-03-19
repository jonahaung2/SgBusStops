import Models
import SwiftUI
import UI

struct BusServiceArrivalCell: View {

	private let model: ArrivalItemViewModel

	init(_ model: ArrivalItemViewModel) {
		self.model = model
	}

	private var serviceArrival: BusServicArrival { model.item.arrival }



	var body: some View {
		Grid(alignment: .centerLastTextBaseline, horizontalSpacing: 4) {
			GridRow(alignment: .lastTextBaseline) {
				ForEach(
					Array(model.item.arrival.arrivals().enumerated()),
					id: \.offset
				) { (index, arrival) in
					ArrivalColumnView(
						arrival: arrival,
						rank: index + 1
					)
					.frame(maxWidth: .infinity)
				}
			}
		}
		.transition(.identity)
	}
}

private struct ArrivalColumnView: View {

	let arrival: BusArrival
	let rank: Int

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			timeView
				.font(font)
				.monospacedDigit()
				.lineLimit(1)
				.minimumScaleFactor(0.7)

			metaView
		}
	}
}

private extension ArrivalColumnView {

	@ViewBuilder
	var timeView: some View {
		if rank == 1, let endDate = countdownEndDate {
			Text(
				timerInterval: Date.now ... endDate,
				pauseTime: .distantPast,
				countsDown: true
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
				Text("Arriving").foregroundStyle(.green)
			case ..<60:
				Text("\(seconds)s")
			default:
				Text("\(seconds / 60)m")
			}
		} else {
			Text("N.A").foregroundStyle(.secondary)
		}
	}
}

private extension ArrivalColumnView {

	var metaView: some View {
		HStack(spacing: 4) {
			loadIcon
			Text(typeText ?? "NA")
				.font(.footnote.weight(.medium).width(.condensed))
				.foregroundStyle(.secondary)

			if isWheelchairAccessible {
				Image(systemName: "wheelchair")
					.font(.caption2.weight(.bold))
					.foregroundStyle(Color.darkYellow)
			}
		}
	}

	@ViewBuilder
	var loadIcon: some View {
		switch arrival.load {
		case .seatsAvailable:
			iconPair("figure.seated.side.right", height: 12, color: .green)
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
private extension Image {

	func iconStyle(height: CGFloat, color: Color) -> some View {
		self
			.resizable()
			.scaledToFit()
			.frame(height: height)
			.foregroundStyle(color)
	}
}

private extension ArrivalColumnView {

	var font: Font {
		switch rank {
		case 1:
				.title.weight(.semibold).width(.condensed)
		case 2:
				.title3.weight(.semibold).width(.condensed)
		default:
				.footnote.weight(.semibold).width(.condensed)
		}
	}
}
