//  RotatingBusMarker.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import UI
import SwiftUI
import CoreLocation

struct RotatingBusMarker: View {
    let title: String
    @State private var isRotating = false
    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
//                LoadingIndicator(44)
//                    .scaleEffect(isPulsing ? 1.15 : 0.9)
//                    .opacity(isPulsing ? 0.35 : 0.8)

                Circle()
                    .stroke(.red.opacity(0.5), lineWidth: 2)
                    .frame(width: 34, height: 34)
                    .rotationEffect(.degrees(isRotating ? 360 : 0))

                Circle()
                    .fill(.green)
                    .frame(width: 24, height: 24)
                    .overlay {
                        Image(systemName: "bus.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
            }
            .shadow(color: .red.opacity(0.35), radius: 10, x: 0, y: 4)
        }
        .onAppear {
            withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                isRotating = true
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
