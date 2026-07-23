//  NetworkClientProtocol.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public protocol NetworkClientProtocol: Sendable {
    func perform<T: Decodable>(_ request: URLRequest) async throws -> T
    func perform(_ request: URLRequest) async throws
    func performAndDecode<T: Decodable, R: NetworkRequest>(_ request: R) async throws -> T
        where R.Response == T
}

public final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let logger: NetworkLogging?

    public init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        logger: NetworkLogging? = nil
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
        self.logger = logger

        // Configure decoder
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        // Configure encoder
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
    }

    public func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        logger?.logRequest(request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logger?.logError(error)
            throw NetworkError.map(error)
        }

        logger?.logResponse(response, data: data)

        try validateResponse(response, data: data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger?.logError(error)
            throw NetworkError.decodingError(error)
        }
    }

    public func perform(_ request: URLRequest) async throws {
        logger?.logRequest(request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logger?.logError(error)
            throw NetworkError.map(error)
        }

        logger?.logResponse(response, data: data)

        try validateResponse(response, data: data)
    }

    public func performAndDecode<T: Decodable, R: NetworkRequest>(_ request: R) async throws -> T
    where R.Response == T {
        let urlRequest = try request.asURLRequest()
        return try await perform(urlRequest)
    }

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "NetworkClient", code: -1))
        }

        switch httpResponse.statusCode {
        case 200 ... 299:
            return
        case 400:
            throw NetworkError.badRequest(data)
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500 ... 599:
            throw NetworkError.serverError(httpResponse.statusCode, data)
        default:
            throw NetworkError.unknown(
                NSError(domain: "NetworkClient", code: httpResponse.statusCode)
            )
        }
    }
}
