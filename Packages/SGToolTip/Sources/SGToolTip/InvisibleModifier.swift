//
//  InvisibleModifier.swift
//  SGPopTip
//
//  Created by Aung Ko Min on 23/5/26.
//


import SwiftUI

struct InvisibleModifier: @MainActor AnimatableModifier {
    var progress: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    func body(content: Content) -> some View {
        content
            .opacity(progress == 1.0 ? 1 : 0)
    }
}
public extension AnyTransition {
    @MainActor
    static func invisible() -> AnyTransition {
        AnyTransition.modifier(
            active: InvisibleModifier(progress: 0),
            identity: InvisibleModifier(progress: 1)
        )
    }
}
struct TextQuakeModifier: @MainActor AnimatableModifier {
    var progress: CGFloat
    let distance: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    func body(content: Content) -> some View {
        content
            .textRenderer(QuakeRenderer(moveAmount: progress == 1 ? 0 : (progress)*distance))
    }
}
public extension AnyTransition {
    @MainActor
    static func textQuake(distance: CGFloat = 5) -> AnyTransition {
        AnyTransition.modifier(
            active: TextQuakeModifier(progress: 0, distance: distance),
            identity: TextQuakeModifier(progress: 1, distance: distance)
        )
    }
}
public struct QuakeRenderer: TextRenderer {
    var moveAmount: Double
    public var animatableData: Double {
        get { moveAmount }
        set { moveAmount = newValue }
    }

    public init(moveAmount: Double) {
        self.moveAmount = moveAmount
    }

    public func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for line in layout {
            for run in line {
                for glyph in run {
                    var copy = context
                    if -moveAmount <= moveAmount {
                        let yOffset = Double.random(in: -moveAmount ... moveAmount)
                        copy.translateBy(x: yOffset, y: 0)
                    }
                    copy.draw(glyph, options: .disablesSubpixelQuantization)
                }
            }
        }
    }
}

public struct ColorfulRender: TextRenderer {
    public init() {}
    public func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for (index, slice) in layout.flattenedRunSlices.enumerated() {
            let degree = Angle.degrees(360 / Double(index + 1))
            var copy = context
            copy.addFilter(.hueRotation(degree))
            copy.draw(slice)
        }
    }
}

extension Text.Layout {
    var flattenedRuns: some RandomAccessCollection<Text.Layout.Run> {
        flatMap { line in
            line
        }
    }
}

extension Text.Layout {
    var flattenedRunSlices: some RandomAccessCollection<Text.Layout.RunSlice> {
        flattenedRuns.flatMap(\.self)
    }
}
