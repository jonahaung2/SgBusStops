//  ViewModel.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Client
import SwiftUI

@MainActor
@Observable
open class ViewModel {

    public var error: UnavailableMessage?
    public var isLoading = false

    @MainActor public func showError(_ errorText: UnavailableMessage?) {
        loading(false)
        error = errorText
    }

    @MainActor public func showError(_ error: Error) {
        if NetworkError.map(error).isConnectivityIssue {
            showError(
                .init(
                    "wifi.slash",
                    title: "You're Offline",
                    description: "Check your internet connection and try again."
                )
            )
            return
        }
        showError(
            .init(
                "exclamationmark.circle.fill",
                title: "Error",
                description: error.localizedDescription
            )
        )
    }

    @MainActor public func showError(
        _ error: Error,
        offlineTitle: String,
        offlineDescription: String,
        fallbackTitle: String = "Error",
        fallbackImageName: String = "exclamationmark.circle.fill"
    ) {
        if NetworkError.map(error).isConnectivityIssue {
            showError(
                .init(
                    "wifi.slash",
                    title: offlineTitle,
                    description: offlineDescription
                )
            )
            return
        }
        showError(
            .init(
                fallbackImageName,
                title: fallbackTitle,
                description: error.localizedDescription
            )
        )
    }

    @MainActor public func clearError() {
        error = nil
    }

    @MainActor public func loading(_ newValue: Bool) {
        isLoading = newValue
    }

    public init() {}
}

public struct UnavailableMessage: Sendable, Hashable {
    public let imageName: String
    public let title: String
    public let description: String

    public init(_ imageName: String = "exclamationmark.circle.fill", title: String = "Error", description: String) {
        self.imageName = imageName
        self.title = title
        self.description = description
    }
}
