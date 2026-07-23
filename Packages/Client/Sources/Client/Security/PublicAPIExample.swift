//  PublicAPIExample.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

enum PublicAPIExampleError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "Missing API key. Set PUBLIC_API_KEY in Config/Secrets.xcconfig."
        case .invalidURL:
            "Invalid request URL."
        case .invalidResponse:
            "The server response is invalid."
        }
    }
}

enum PublicAPIExample {
    static func authenticatedGet(urlString: String, acceptHeader: String?) async throws -> (statusCode: Int, body: String) {
        guard let apiKey = AppSecrets.apiKey(), !apiKey.isEmpty else {
            throw PublicAPIExampleError.missingAPIKey
        }
        guard let url = URL(string: urlString) else {
            throw PublicAPIExampleError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "AccountKey")
        if let acceptHeader, !acceptHeader.isEmpty {
            request.setValue(acceptHeader, forHTTPHeaderField: "Accept")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PublicAPIExampleError.invalidResponse
        }
        let body = String(decoding: data, as: UTF8.self)
        return (httpResponse.statusCode, body)
    }
}
