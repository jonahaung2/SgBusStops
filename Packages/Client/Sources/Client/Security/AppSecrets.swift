//  AppSecrets.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public enum AppSecrets {
    private static let apiKeyInfoKey = "PUBLIC_API_KEY"
    private static let keychainAccount = "public_api_key"

    public static func bootstrapAPIKey() {
        guard let value = bundleAPIKey else {
            return
        }
        _ = try? APIKeychain.shared.store(value: value, account: keychainAccount)
    }

    public static func apiKey() -> String? {
        if let value = try? APIKeychain.shared.read(account: keychainAccount),
           !value.isEmpty {
            return value
        }
        return bundleAPIKey
    }

    private static var bundleAPIKey: String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: apiKeyInfoKey) as? String else {
            return nil
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "$(PUBLIC_API_KEY)" else {
            return nil
        }
        return trimmed
    }
}
