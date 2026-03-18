import Models
import SwiftUI
import UI

struct BusServicArrivalCell: View {

	private let model: ArrivalItemViewModel

	init(_ model: ArrivalItemViewModel) {
		self.model = model
	}
	
	private var serviceArrival: BusServicArrival { model.busServiceArrival }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Grid(alignment: .centerLastTextBaseline, horizontalSpacing: 4) {
                GridRow(alignment: .lastTextBaseline) {
                    if let arrival = serviceArrival.nextBus {
                        arrivalColumn(title: "Next", arrival: arrival, rank: 1, date: .now)
                            .frame(maxWidth: .infinity)
                    } else {
                        Color.clear.frame(maxWidth: .infinity)
                    }
                    if let arrival = serviceArrival.nextBus2 {
                        arrivalColumn(title: "2nd", arrival: arrival, rank: 2, date: .now)
                            .frame(maxWidth: .infinity)
                    } else {
                        Color.clear.frame(maxWidth: .infinity)
                    }
                    if let arrival = serviceArrival.nextBus3 {
                        arrivalColumn(title: "3rd", arrival: arrival, rank: 3, date: .now)
                            .frame(maxWidth: .infinity)
                    } else {
                        Color.clear.frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private func createDescription(for arrival: BusArrival) -> String {
        var string = String()
        if let text = arrival.originCode {
            string.append(text)
        }
        if let text = arrival.destinationCode {
            string.append("\n\(text)")
        }
        if let int = arrival.visitNumber {
            string.append("\nvisit: \(int)")
        }
        return string
    }

    private func arrivalColumn(title _: String, arrival: BusArrival, rank: Int, date: Date) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .lastTextBaseline) {
                if rank == 1, let date = countdownEndDate(for: arrival) {
                    Text(
                        timerInterval: Date.now ... date,
                        pauseTime: .distantPast,
                        countsDown: true,
                    )
                } else {
                    arrivalText(for: arrival, now: date)
                }
            }
            .font(font(for: rank))
            .monospacedDigit()
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            HStack(spacing: 4) {
                switch arrival.load {
                case .seatsAvailable:
                    HStack(spacing: -2) {
                        Image(systemName: "figure.seated.side.right")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 12)
                        Image(systemName: "figure.seated.side.right")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 12)
                    }.foregroundStyle(Color(hue: 0.273, saturation: 0.49, brightness: 0.62))
                case .standingAvailable:
                    HStack(spacing: -2) {
                        Image(systemName: "figure.wave")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 15)
                        Image(systemName: "figure.wave")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 15)
                    }.foregroundStyle(Color.darkYellow)
                case .limitedStanding:
                    HStack(spacing: -2) {
                        Image(systemName: "figure.taichi")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 15)
                        Image(systemName: "figure.wave")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 15)
                    }.foregroundStyle(Color(hue: 0.0, saturation: 0.85, brightness: 1.0).gradient)
                case .none:
                    EmptyView()
                }
//                Image(systemName: loadText(for: arrival))
//                    .resizable()
//                    .scaledToFit()
//                    .foregroundStyle(loadColor(for: arrival))
//                    .frame(height: 15)
//                    .symbolRenderingMode(.multicolor)
//                //				Text(loadText(for: arrival))
//                //					.font(.footnote.weight(.semibold))
//                //					.foregroundStyle(loadColor(for: arrival))
                let typeText = typeText(for: arrival) ?? "NA"
                Text(typeText)
                    .font(.footnote.weight(.medium).width(.condensed))
                    .foregroundStyle(.secondary)
                if isWheelchairAccessible(arrival) {
                    Image(systemName: "wheelchair")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.darkYellow)
                }
            }
        }
        //		.background(
        //			RoundedRectangle(cornerRadius: 12, style: .continuous)
        //				.fill(isPrimary ? Color.accentColor.opacity(0.08) : Color(.systemBackground))
        //		)
        //		.overlay {
        //			if isPrimary {
        //				RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.clear)
        //					.runningBorder(lineWidth: 2, cornerRadius: 12)
        //			} else {
        //				RoundedRectangle(cornerRadius: 12, style: .continuous)
        //					.stroke(isPrimary ? Color.darkGreen : Color.primary.opacity(0.05), lineWidth: 1)
        //			}
        //
        //		}
    }

    private func font(for rank: Int) -> Font {
        if rank == 1 {
            return Font.title.weight(.semibold).width(.condensed)
        }
        if rank == 2 {
            return .title3.weight(.semibold).width(.condensed)
        }

        return .footnote.weight(.semibold).width(.condensed)
    }

    private var operatorBackgroundColor: Color {
        switch serviceArrival.operatorCode {
        case .sbst:
            .red.opacity(0.14)
        case .smrt:
            .green.opacity(0.14)
        case .tts:
            .blue.opacity(0.14)
        case .gas:
            .orange.opacity(0.14)
        }
    }

    private var operatorForegroundColor: Color {
        switch serviceArrival.operatorCode {
        case .sbst:
            .red
        case .smrt:
            .green
        case .tts:
            .blue
        case .gas:
            .orange
        }
    }

    @ViewBuilder
    private func arrivalText(for arrival: BusArrival, now: Date) -> some View {
        if let seconds = arrival.arrivalSeconds(now: now) {
            if seconds <= -60 {
                Text("Departed").foregroundStyle(Color.red)
            } else if seconds <= 30 {
                Text("Arriving").foregroundStyle(Color.green)
            } else if seconds <= 60 {
                Text("\(seconds)s")
            } else {
                let minutes = Int(seconds.dividedReportingOverflow(by: 60).partialValue)
                Text("\(minutes)m").foregroundStyle(.primary)
            }
        } else {
            Text("N.A").foregroundStyle(.secondary)
        }
    }

    private func loadText(for arrival: BusArrival?) -> String {
        switch arrival?.load {
        case .seatsAvailable: "figure.seated.side.right"
        case .standingAvailable: "figure.wave"
        case .limitedStanding: "figure.play"
        case .none: "minus.circle.fill"
        }
    }

    private func loadColor(for arrival: BusArrival?) -> Color {
        switch arrival?.load {
        case .seatsAvailable: .green.mix(with: .gray, by: 0.1)
        case .standingAvailable: .orange
        case .limitedStanding: .red
        case .none: .secondary
        }
    }

    private func typeText(for arrival: BusArrival?) -> String? {
        switch arrival?.type {
        case .singleDeck: "Single"
        case .doubleDeck: "Double"
        case .bendy: "Bendy"
        case .none: nil
        }
    }

    private func isWheelchairAccessible(_ arrival: BusArrival?) -> Bool {
        arrival?.feature == .wheelchairAccessible
    }

    private func countdownEndDate(for arrival: BusArrival) -> Date? {
        guard let seconds = arrival.arrivalSeconds(), seconds > 0 else {
            return nil
        }
        return Date(timeInterval: Double(seconds), since: .now)
    }
}
