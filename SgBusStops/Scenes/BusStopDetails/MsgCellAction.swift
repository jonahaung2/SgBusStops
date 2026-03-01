//
//  MsgCellAction.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import SwiftUI

public struct RefreshAction {
    public let action: (String) -> Void
    public func callAsFunction(value: String) {
        action(value)
    }
}

public extension EnvironmentValues {
    @Entry var refreshAction: RefreshAction?
}
