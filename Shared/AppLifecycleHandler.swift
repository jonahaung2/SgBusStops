//  AppLifecycleHandler.swift
//
//  Copyright © 2026 Aung Ko Min.
//

//
//  AppLifecycleHandler.swift
//  Services
//
//  Created by Aung Ko Min on 18/3/26.
//

import SwiftUI

public struct AppLifecycleHandler: ViewModifier {
    let onActive: () -> Void
    let onBackground: () -> Void

    @Environment(\.scenePhase) private var scenePhase

    public func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { oldValue, newValue in
                switch newValue {
                case .active:
                    onActive()
                case .background,
                     .inactive:
                    onBackground()
                @unknown default:
                    break
                }
            }
    }
}

public extension View {
    func onAppLifecycle(
        active: @escaping () -> Void,
        background: @escaping () -> Void
    ) -> some View {
        modifier(AppLifecycleHandler(onActive: active, onBackground: background))
    }
}
