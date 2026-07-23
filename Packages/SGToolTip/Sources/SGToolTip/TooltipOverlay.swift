//
//  InvisibleModifier.swift
//  SGPopTip
//
//  Created by Aung Ko Min on 23/5/26.
//

import SwiftUI

struct TooltipOverlay<Content: View>: View, Equatable {
    nonisolated static func == (lhs: TooltipOverlay<Content>, rhs: TooltipOverlay<Content>) -> Bool {
        lhs.value.id == rhs.value.id
    }
    let value: SGTooltipValue
    @ViewBuilder let content: () -> Content
    let onClose: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                Rectangle().fill(Color.black.opacity(0.0001))
                    .ignoresSafeArea()
                    .gesture(DragGesture(minimumDistance: 0).onEnded({ _ in
                        handleDismiss()
                    }))
                SGTooltip(
                    value: value,
                    screenBounds: proxy.frame(in: .global).inset(
                        by: UIEdgeInsets(
                            top: proxy.safeAreaInsets.top,
                            left: proxy.safeAreaInsets.leading,
                            bottom: proxy.safeAreaInsets.bottom,
                            right: proxy.safeAreaInsets.trailing
                        )
                    ),
                    onClose: {
                        handleDismiss()
                    }
                ) {
                    content()
                }
            }
            .ignoresSafeArea()
            .presentationBackground(.clear)
            .transition(.invisible())
        }
    }

    private func handleDismiss() {
        UIImpactFeedbackGenerator().impactOccurred(intensity: 0.5)
        onClose()
    }
}
