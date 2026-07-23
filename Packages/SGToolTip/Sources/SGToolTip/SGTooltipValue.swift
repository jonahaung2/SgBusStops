//
//  SGTooltipValue.swift
//  SGPopTip
//
//  Created by Aung Ko Min on 22/11/25.
//

import Foundation

public struct SGTooltipValue: Sendable, Hashable, Identifiable {
    public var id = UUID().uuidString
	public let rect: CGRect
	public let arrowDirection: ArrowDirection

	public init(_ rect: CGRect, _ arrowDirection: ArrowDirection) {
		self.rect = rect
		self.arrowDirection = arrowDirection
	}
}
