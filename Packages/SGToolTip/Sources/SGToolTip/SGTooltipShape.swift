//
//  InvisibleModifier.swift
//  SGPopTip
//
//  Created by Aung Ko Min on 23/5/26.
//

import SwiftUI

public struct SGTooltipShape: Shape {
    private let direction: ArrowDirection
    private let horizontalAnchor: CGFloat?

    public init(
        direction: ArrowDirection,
        horizontalAnchor: CGFloat? = nil
    ) {
        self.direction = direction
        self.horizontalAnchor = horizontalAnchor
    }

    private let cornerRadius: CGFloat = 16
    private let arrowWidth: CGFloat = 23
    private let arrowHeight: CGFloat = 12

    public func path(in rect: CGRect) -> Path {
        let norm = normalize(direction)
        let metrics = makeMetrics(for: rect, edge: norm.edge)
        switch norm.edge {
        case .top:
            let centerX = resolvedHorizontalCenter(
                in: rect,
                offset: norm.offset,
                metrics: metrics,
                anchor: horizontalAnchor
            )
            return pathWithTopArrow(in: rect, centerX: centerX, metrics: metrics)
        case .bottom:
            let centerX = resolvedHorizontalCenter(
                in: rect,
                offset: norm.offset,
                metrics: metrics,
                anchor: horizontalAnchor
            )
            return pathWithBottomArrow(in: rect, centerX: centerX, metrics: metrics)
        }
    }

    private enum EdgeKind { case top, bottom }

    private func normalize(_ direction: ArrowDirection) -> (edge: EdgeKind, offset: CGFloat) {
        switch direction {
        case .top(let o), .topLeading(let o), .topTrailing(let o):
            return (.top, o)
        case .bottom(let o), .bottomLeading(let o), .bottomTrailing(let o):
            return (.bottom, o)
        }
    }

    private struct GeometryMetrics {
        let cornerRadius: CGFloat
        let arrowBase: CGFloat
        let arrowHeight: CGFloat
    }

    private func makeMetrics(for rect: CGRect, edge: EdgeKind) -> GeometryMetrics {
        let epsilon: CGFloat = 0.001
        var cr = min(cornerRadius, rect.width * 0.5, rect.height * 0.5)
        var ab: CGFloat
        var ah: CGFloat
        switch edge {
        case .top, .bottom:
            ah = min(arrowHeight, max(0, rect.height - cr - epsilon))
            cr = min(cr, rect.height - ah - epsilon)
            ab = min(arrowWidth, max(0, rect.width - 2 * cr))
        }
        return GeometryMetrics(cornerRadius: cr, arrowBase: ab, arrowHeight: ah)
    }

    private func resolvedHorizontalCenter(
        in rect: CGRect,
        offset: CGFloat,
        metrics: GeometryMetrics,
        anchor: CGFloat?
    ) -> CGFloat {
        let minCenter = metrics.cornerRadius + metrics.arrowBase / 2
        let maxCenter = rect.width - metrics.cornerRadius - metrics.arrowBase / 2
        let center: CGFloat
        if let anchor {
            center = anchor
        } else if offset.isInfinite {
            center = rect.midX
        } else if offset == .greatestFiniteMagnitude {
            center = maxCenter
        } else {
            center = minCenter + offset
        }
        return clamp(center, min: minCenter, max: maxCenter)
    }

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.max(min, Swift.min(max, value))
    }

    private func pathWithBottomArrow(in rect: CGRect, centerX: CGFloat, metrics: GeometryMetrics) -> Path {
        let cr = metrics.cornerRadius
        let ab = metrics.arrowBase
        let ah = metrics.arrowHeight
        let arrowLeftX = centerX - ab / 2
        let arrowRightX = centerX + ab / 2
        var path = Path()

        path.move(to: CGPoint(x: cr, y: 0))
        path.addLine(to: CGPoint(x: rect.width - cr, y: 0))
        path.addArc(center: CGPoint(x: rect.width - cr, y: cr),
                    radius: cr,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(0),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cr - ah))
        path.addArc(center: CGPoint(x: rect.width - cr, y: rect.height - cr - ah),
                    radius: cr,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)
        path.addLine(to: CGPoint(x: arrowRightX, y: rect.height - ah))
        path.addLine(to: CGPoint(x: centerX, y: rect.height))
        path.addLine(to: CGPoint(x: arrowLeftX, y: rect.height - ah))
        path.addLine(to: CGPoint(x: cr, y: rect.height - ah))
        path.addArc(center: CGPoint(x: cr, y: rect.height - cr - ah),
                    radius: cr,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: cr))
        path.addArc(center: CGPoint(x: cr, y: cr),
                    radius: cr,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)

        return path
    }

    private func pathWithTopArrow(in rect: CGRect, centerX: CGFloat, metrics: GeometryMetrics) -> Path {
        let cr = metrics.cornerRadius
        let ab = metrics.arrowBase
        let ah = metrics.arrowHeight
        let arrowLeftX = centerX - ab / 2
        let arrowRightX = centerX + ab / 2
        var path = Path()

        path.move(to: CGPoint(x: cr, y: ah))
        path.addLine(to: CGPoint(x: arrowLeftX, y: ah))
        path.addLine(to: CGPoint(x: centerX, y: 0))
        path.addLine(to: CGPoint(x: arrowRightX, y: ah))
        path.addLine(to: CGPoint(x: rect.width - cr, y: ah))
        path.addArc(center: CGPoint(x: rect.width - cr, y: ah + cr),
                    radius: cr,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(0),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cr))
        path.addArc(center: CGPoint(x: rect.width - cr, y: rect.height - cr),
                    radius: cr,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)
        path.addLine(to: CGPoint(x: cr, y: rect.height))
        path.addArc(center: CGPoint(x: cr, y: rect.height - cr),
                    radius: cr,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: ah + cr))
        path.addArc(center: CGPoint(x: cr, y: ah + cr),
                    radius: cr,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)

        return path
    }
}
