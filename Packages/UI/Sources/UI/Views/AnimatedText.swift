//  AnimatedText.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI

public struct AnimatedText: View {
    public enum AnimationPreset {
        case spring
        case wave
        case bounce
        case typewriter
    }

    public let letters: [Character]

    @State private var isVisible = false
    @State private var offset: CGSize
    @State private var isDisappearing = false

    private let preset: AnimationPreset
    private let initialOffset: CGSize
    private let delayStep: Double
    private let jitter: CGFloat
    private let style: (Character) -> Text

    public init(
        text: String,
        preset: AnimationPreset = .spring,
        initialOffset: CGSize = CGSize(width: 0, height: 300),
        delayStep: Double = 0.05,
        jitter: CGFloat = 0,
        @ViewBuilder style: @escaping (Character) -> Text = {
            Text(String($0)).font(.title.bold().width(.condensed).lowercaseSmallCaps())
        }
    ) {
        letters = Array(text)
        self.preset = preset
        self.initialOffset = initialOffset
        self.delayStep = delayStep
        self.jitter = jitter
        self.style = style
        _offset = State(initialValue: initialOffset)
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(letters.indices, id: \.self) { index in
                style(letters[index])
                    .rotationEffect(rotation(for: index), anchor: .bottom)
                    .offset(offsetFor(index))
                    .opacity(opacity(for: index))
                    .animation(
                        animation(for: index),
                        value: offset
                    )
            }
        }
        .padding()
        .onAppear {
            isDisappearing = false
            withAnimation {
                offset = .zero
                isVisible = true
            }
        }
        .onDisappear {
            isDisappearing = true
            withAnimation {
                offset = initialOffset
                isVisible = false
            }
        }
    }
}

private extension AnimatedText {
    func animation(for index: Int) -> Animation {
        baseAnimation()
            .delay(staggerDelay(for: index))
    }

    func baseAnimation() -> Animation {
        switch preset {
        case .spring:
            .interpolatingSpring(stiffness: 170, damping: 15)
        case .wave:
            .easeInOut(duration: 0.6)
        case .bounce:
            .spring(response: 0.4, dampingFraction: 0.5)
        case .typewriter:
            .easeOut(duration: 0.2)
        }
    }

    func staggerDelay(for index: Int) -> Double {
        if isDisappearing {
            Double(letters.count - index) * delayStep
        } else {
            Double(index) * delayStep
        }
    }
}

private extension AnimatedText {
    func offsetFor(_ index: Int) -> CGSize {
        var base = offset

        // Add jitter if enabled
        if jitter > 0 {
            let randomX = CGFloat.random(in: -jitter ... jitter)
            let randomY = CGFloat.random(in: -jitter ... jitter)
            base.width += randomX
            base.height += randomY
        }

        // Wave effect
        if preset == .wave {
            let wave = sin(Double(index)) * 10
            base.height += isVisible ? 0 : CGFloat(wave)
        }

        return base
    }

    func rotation(for _: Int) -> Angle {
        switch preset {
        case .bounce:
            .degrees(isVisible ? 0 : 180)
        default:
            .degrees(isVisible ? 0 : 360)
        }
    }

    func opacity(for _: Int) -> Double {
        switch preset {
        case .typewriter:
            isVisible ? 1 : 0
        default:
            1
        }
    }
}
