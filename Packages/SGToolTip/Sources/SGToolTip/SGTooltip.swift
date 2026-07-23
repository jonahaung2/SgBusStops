//
//  InvisibleModifier.swift
//  SGPopTip
//
//  Created by Aung Ko Min on 23/5/26.
//

import SwiftUI

public struct SGTooltipConfiguration {
    let backgroundColor = Color(red: 0.865, green: 1, blue: 0.865)
    let tintColor = Color(red: 0.36, green: 0.33, blue: 0.62)
    let arrowPadding: CGFloat = 12
    let padding: CGFloat = 16
    let contentPadding: CGFloat = 8
}

public struct SGTooltip<Content: View>: View {
    private let value: SGTooltipValue
    private let screenBounds: CGRect
    private let config = SGTooltipConfiguration()
    private let content: () -> Content
    private let onClose: (() -> Void)?

    @State private var isVisible = false
    @State private var height: CGFloat = 0
    @State private var width: CGFloat = 0
    @State private var intrinsicWidth: CGFloat = 0

    private var direction: ArrowDirection { value.arrowDirection }

    public init(
        value: SGTooltipValue,
        screenBounds: CGRect,
        onClose: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.value = value
        self.screenBounds = screenBounds
        self.onClose = onClose
        self.content = content
    }

    public var body: some View {
        tooltipContent
            .frame(width: fittedWidth, alignment: .leading)
            .background {
                tooltipContent
                    .fixedSize(horizontal: true, vertical: false)
                    .readWidth($intrinsicWidth)
                    .hidden()
                    .allowsHitTesting(false)
            }
            .readHeight($height)
            .readWidth($width)
            .transition(.invisible())
            .tint(config.tintColor)
            .font(.system(size: UIFont.systemFontSize))
            .onAppear(perform: show)
    }
}

private extension SGTooltip {
    var tooltipContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            topBar

            content()
                .padding(.horizontal, config.contentPadding)

            bottomSpacer
        }
        .background(config.backgroundColor)
        .padding(config.contentPadding)
        .padding(arrowPaddingEdge, config.arrowPadding)
        .background(bubble)
        .offset(tooltipOffset)
    }

    var fittedWidth: CGFloat? {
        guard intrinsicWidth > 0 else {
            return resolvedMaxWidth
        }
        guard let resolvedMaxWidth else {
            return intrinsicWidth
        }
        return min(intrinsicWidth, resolvedMaxWidth)
    }
}

// MARK: - Subviews

private extension SGTooltip {

    var topBar: some View {
        HStack {
            Spacer()
//            closeButton
        }
        .frame(height: 8)
    }

    var bottomSpacer: some View {
        Color.clear
            .frame(height: 8)
    }

    var closeButton: some View {
        Button(action: dismiss) {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 15, height: 15)
                .fontWeight(.bold)
                .imageScale(.large)
        }
    }

    var bubble: some View {
        SGTooltipShape(
            direction: direction,
            horizontalAnchor: horizontalArrowAnchor
        )
        .fill(config.backgroundColor)
            .shadow(color: .black.opacity(0.14), radius: 2, x: 0, y: 2)
            .shadow(color: .black.opacity(0.10), radius: 3, x: 0, y: 0)
            .padding(1)
    }
}

// MARK: - Layout

private extension SGTooltip {

    var tooltipOffset: CGSize {
        CGSize(
            width: xOffset,
            height: yOffset
        )
    }
    @inline(__always)

    func adjustedX(
        for rect: CGRect,
        in parent: CGRect
    ) -> CGFloat {
        guard
            rect.origin.x.isFinite,
            rect.width.isFinite,
            parent.minX.isFinite,
            parent.maxX.isFinite,
            parent.width.isFinite,
            parent.width > 0
        else {
            return parent.minX.isFinite ? parent.minX : .zero
        }
        return min(
            max(rect.origin.x, parent.minX),
            parent.maxX - rect.width
        )
    }

    var xOffset: CGFloat {
        let proposedX: CGFloat
        switch horizontalEdge {
        case .leading:
            proposedX = screenBounds.minX + config.padding
        case .trailing:
            proposedX = value.rect.maxX - value.rect.width - config.padding
        }
        return adjustedX(
            for: CGRect(x: proposedX, y: 0, width: width, height: 0),
            in: screenBounds
        )
    }

    var yOffset: CGFloat {
        switch verticalEdge {
        case .top:
            value.rect.maxY

        case .bottom:
            value.rect.minY - height
        }
    }

    var resolvedMaxWidth: CGFloat? {
        guard screenBounds.width.isFinite else {
            return nil
        }
        let width = screenBounds.width - (config.padding * 2)
        return width > 0 ? width : nil
    }

    var horizontalArrowAnchor: CGFloat? {
        arrowTargetX - xOffset
    }

    var arrowTargetX: CGFloat {
        switch direction {
        case .top, .bottom:
            value.rect.midX
        case .topLeading, .bottomLeading:
            value.rect.minX
        case .topTrailing, .bottomTrailing:
            value.rect.maxX
        }
    }

    var arrowPaddingEdge: Edge.Set {
        arrowEdge == .top ? .top : .bottom
    }
}

// MARK: - Direction Helpers

private extension SGTooltip {

    var arrowEdge: Edge {
        switch direction {
        case .top, .topLeading, .topTrailing:
            return .top

        case .bottom, .bottomLeading, .bottomTrailing:
            return .bottom
        }
    }

    var verticalEdge: VerticalEdge {
        switch direction {
        case .top, .topLeading, .topTrailing:
            return .top

        case .bottom, .bottomLeading, .bottomTrailing:
            return .bottom
        }
    }

    var horizontalEdge: HorizontalEdge {
        switch direction {
        case .topTrailing, .bottomTrailing:
            return .trailing
        case .top, .topLeading, .bottom, .bottomLeading:
            return .leading
        }
    }

    var scaleAnchor: UnitPoint {
        switch direction {
        case .top:
            return .top
        case .topLeading:
            return .topLeading
        case .topTrailing:
            return .topTrailing

        case .bottom:
            return .bottom
        case .bottomLeading:
            return .bottomLeading
        case .bottomTrailing:
            return .bottomTrailing
        }
    }
}

// MARK: - Actions

private extension SGTooltip {

    func show() {
        isVisible = true
    }

    func dismiss() {
        onClose?()
    }
}

// MARK: - Height Reader

private extension View {

    func readHeight(_ height: Binding<CGFloat>) -> some View {
        onGeometryChange(for: CGFloat.self) { proxy in
            proxy.frame(in: .local).height
        } action: { newValue in
            height.wrappedValue = newValue
        }
    }

    func readWidth(_ width: Binding<CGFloat>) -> some View {
        onGeometryChange(for: CGFloat.self) { proxy in
            proxy.frame(in: .local).width
        } action: { newValue in
            width.wrappedValue = newValue
        }
    }
}
