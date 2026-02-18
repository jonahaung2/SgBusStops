//
//  BusStopRepository.swift
//  SG Bus Stops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Client
import Foundation

struct HTTPResponse {
    let statusCode: Int
    let body: String
}

struct BusStopRepository {
    private let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()

    private let baseURL = URL(string: "https://datamall2.mytransport.sg/ltaodataservice/BusStops")!

    /// Fetch raw response (status + body as text)
    func fetchBusStops(top: Int) async throws -> HTTPResponse {
        var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "$top", value: String(top))]
        let url = comps.url!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        try request.setValue(apiKey(), forHTTPHeaderField: "AccountKey")

        let (data, response) = try await session.data(for: request)
        let http = response as? HTTPURLResponse
        let status = http?.statusCode ?? -1
        let bodyString = String(data: data, encoding: .utf8) ?? ""
        return HTTPResponse(statusCode: status, body: bodyString)
    }

    /// Fetch decoded bus stops
    func fetchBusStopsDecoded(top: Int) async throws -> [BusStop] {
        var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "$top", value: String(top))]
        let url = comps.url!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        try request.setValue(apiKey(), forHTTPHeaderField: "AccountKey")

        let (data, _) = try await session.data(for: request)
        let decoded = try JSONDecoder().decode(BusStopsEnvelope.self, from: data)
        return decoded.value
    }

    private func apiKey() throws -> String {
        // Retrieve API key stored by ContentView under account: "public_api_key"
        let maybeKey = try APIKeychain.shared.read(account: "public_api_key")
        guard let key = maybeKey, !key.isEmpty else {
            throw NSError(domain: "BusStopRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing API Key. Save it first."])
        }
        return key
    }
}
