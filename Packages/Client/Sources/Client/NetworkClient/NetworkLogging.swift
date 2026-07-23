//  NetworkLogging.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import OSLog
import Foundation

public protocol NetworkLogging: Sendable {
    func logRequest(_ request: URLRequest)
    func logResponse(_ response: URLResponse, data: Data)
    func logError(_ error: Error)
}

public final class NetworkLogger: NetworkLogging {
    private let logger: Logger = .init(subsystem: "com.app.network", category: "network")
    private let isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    public func logRequest(_ request: URLRequest) {
        guard isEnabled else { return }

        logger.debug("📤 Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")

        if let headers = request.allHTTPHeaderFields {
            logger.debug("Headers: \(headers)")
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            logger.debug("Body: \(bodyString)")
        }
    }

    public func logResponse(_ response: URLResponse, data: Data) {
        guard isEnabled else { return }

        if let httpResponse = response as? HTTPURLResponse {
            logger.debug("📥 Response: \(httpResponse.statusCode)")

            if let dataString = String(data: data, encoding: .utf8) {
                logger.debug("Data: \(dataString)")
            }
        }
    }

    public func logError(_ error: Error) {
        guard isEnabled else { return }

        let nsError = error as NSError

        if let urlError = error as? URLError {
            logger.error(
                "❌ Network Error: domain=\(nsError.domain) code=\(nsError.code) urlCode=\(urlError.code.rawValue) description=\(nsError.localizedDescription)"
            )
            return
        }

        logger.error(
            "❌ Error: type=\(String(describing: type(of: error))) domain=\(nsError.domain) code=\(nsError.code) description=\(nsError.localizedDescription)"
        )
    }
}
