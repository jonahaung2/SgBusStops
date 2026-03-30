//
//  BusNumberText.swift
//  UI
//
//  Created by Aung Ko Min on 20/3/26.
//

import SwiftUI

public struct BusNumberText: View {
    private let text: String
    private let textStyle: UIFont.TextStyle

    public init(_ text: String, _ textStyle: UIFont.TextStyle) {
        self.text = text
        self.textStyle = textStyle
    }

    public var body: some View {
        Text(text)
            .font(.custom("Impact", size: UIFont.preferredFont(forTextStyle: textStyle).pointSize))
			.foregroundStyle(Color.indigo.mix(with: .primary, by: 0.3).gradient)
    }
}
