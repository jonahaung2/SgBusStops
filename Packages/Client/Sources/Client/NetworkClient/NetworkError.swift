//  NetworkError.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case missingAPIKey
    case offline
    case timedOut
    case decodingError(Error)
    case encodingError(Error)
    case badRequest(Data?)
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int, Data?)
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .noData:
            "No data received"
        case .missingAPIKey:
            "Missing API key"
        case .offline:
            "No internet connection"
        case .timedOut:
            "The request timed out"
        case let .decodingError(error):
            "Failed to decode response: \(error.localizedDescription)"
        case let .encodingError(error):
            "Failed to encode request: \(error.localizedDescription)"
        case .badRequest:
            "Bad request"
        case .unauthorized:
            "Unauthorized access"
        case .forbidden:
            "Forbidden access"
        case .notFound:
            "Resource not found"
        case let .serverError(code, _):
            "Server error with code: \(code)"
        case let .unknown(error):
            "Unknown error: \(error.localizedDescription)"
        }
    }

    public var isConnectivityIssue: Bool {
        switch self {
        case .offline,
             .timedOut:
            return true
        case let .unknown(error):
            if let urlError = error as? URLError {
                return Self.map(urlError).isConnectivityIssue
            }
            return false
        default:
            return false
        }
    }

    public static func map(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }

        guard let urlError = error as? URLError else {
            return .unknown(error)
        }

        switch urlError.code {
        case .callIsActive,
             .cannotConnectToHost,
             .cannotFindHost,
             .dataNotAllowed,
             .dnsLookupFailed,
             .internationalRoamingOff,
             .networkConnectionLost,
             .notConnectedToInternet:
            return .offline
        case .timedOut:
            return .timedOut
        default:
            return .unknown(urlError)
        }
    }
}

// MARK: - HTTP Methods

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Network Request Protocol

public protocol NetworkRequest {
    associatedtype Response: Decodable

    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Encodable? { get }
    var timeoutInterval: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}

public extension NetworkRequest {
    var baseURL: URL {
        URL(string: "https://datamall2.mytransport.sg/") ?? URL(fileURLWithPath: "/")
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var body: Encodable? {
        nil
    }

    var timeoutInterval: TimeInterval {
        60
    }

    var cachePolicy: URLRequest.CachePolicy {
        .useProtocolCachePolicy
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems

        guard let finalURL = components?.url else {
            throw NetworkError.invalidURL
        }
        var headers = headers
        headers?["AccountKey"] = try apiKey()

        var request = URLRequest(
            url: finalURL,
            cachePolicy: cachePolicy,
            timeoutInterval: timeoutInterval
        )
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        if let body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }

        return request
    }

    private func apiKey() throws -> String {
        let maybeKey = AppSecrets.apiKey()
        guard let key = maybeKey, !key.isEmpty else {
            throw NetworkError.missingAPIKey
        }
        return key
    }
}
