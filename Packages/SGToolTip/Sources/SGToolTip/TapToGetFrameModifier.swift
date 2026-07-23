//
//  InvisibleModifier.swift
//  SGPopTip
//
//  Created by Aung Ko Min on 23/5/26.
//

import SwiftUI

private struct TapToGetFrameModifier<ContentView: View>: ViewModifier {
    let arrowDirection: ArrowDirection
    @ViewBuilder let contentView: () -> ContentView
    @State private var sourceRect: CGRect = .zero
    @State private var item: SGTooltipValue?
    @State private var observeFrame = false

    func body(content: Content) -> some View {
        Button {
            observeFrame = true
        } label: {
            content
        }
        .buttonStyle(.plain)
        .disabled(observeFrame)
            .background {
                if observeFrame {
                    Color.clear
                        
                        .onGeometryChange(for: CGRect.self) { proxy in
                            proxy.frame(in: .global)
                        } action: { newValue in
                           
                            UIImpactFeedbackGenerator().impactOccurred(intensity: 0.5)
                            withTransaction(\.disablesAnimations, true) {
                                item = .init(newValue, arrowDirection)
                            }
                        }
                        .fullScreenCover(
                            item: $item,
                            onDismiss: onDismissTooltip
                        ) { item in
                            TooltipOverlay(value: item) {
                                contentView()
                            } onClose: {
                                onDismissTooltip()
                            }
                        }
                }
            }
            
            
    }

    private func onDismissTooltip() {
        observeFrame = false
        withTransaction(\.disablesAnimations, true) {
            item = nil
        }
    }
}
extension View {
    public func sgToolTip(_ arrowDirection: ArrowDirection, @ViewBuilder contentView: @escaping () -> some View)
        -> some View
    {
        ModifiedContent(
            content: self,
            modifier: TapToGetFrameModifier(arrowDirection: arrowDirection, contentView: contentView)
        )
    }
}
