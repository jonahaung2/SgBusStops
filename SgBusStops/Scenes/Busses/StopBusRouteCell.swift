struct StopBusRouteCell: View {
	let stop: Stop
	let item: BusRoute
	@Environment(BusStore.self) private var store
	@Environment(NavRouter.self) private var navRouter
	var body: some View {
		let string: String = {
			if let last = item.route.routes.last, let lastStop = store.busStop(
				for: last.busStopCode
			) {
				if let first = item.route.routes.first, let firstStop = store.busStop(
					for: first.busStopCode
				) {
					return "\(firstStop.desc) - \(lastStop.desc)"
				} else {
					return lastStop.desc
				}
			} else {
				if let first = item.route.routes.first, let firstStop = store.busStop(
					for: first.busStopCode
				) {
					return firstStop.desc
				} else {
					return "\(item.route.routes.count) stops"
				}
			}
		}()
		let busNumber = Text(item.bus.busNumber).font(.custom("Impact", size: UIFont.preferredFont(forTextStyle: .title2).pointSize)).foregroundStyle(
			Color.indigo.mix(with: .primary, by: 0.3).gradient
		)
		let text = Text(string).font(.callout).foregroundStyle(.secondary)

		NavigationLink(value: item) {
			Text("\(busNumber)  \(text)")
				.lineHeight(.leading(increase: 1.2))
				.italic()
		}
	}
}
