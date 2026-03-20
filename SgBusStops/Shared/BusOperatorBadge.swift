import Models
import SwiftUI

extension BusOperator {
    @ViewBuilder
    var badge: some View {
        switch self {
        case .sbst, .smrt, .tts:
            Image(rawValue)
                .resizable()
                .scaledToFit()
        case .gas:
            Text(rawValue)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}
