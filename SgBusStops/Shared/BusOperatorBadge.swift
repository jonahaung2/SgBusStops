import Models
import SwiftUI

extension BusOperator {
    @ViewBuilder
    var badge: some View {
		Image(rawValue)
			.resizable()
			.scaledToFit()
    }
}
