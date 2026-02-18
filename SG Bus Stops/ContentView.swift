//
//  ContentView.swift
//  SG Bus Stops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Client
import SwiftUI

struct ContentView: View {
    @State private var isLoading = false
    @State private var apiKeyInput = ""
    @State private var requestURL = "https://datamall2.mytransport.sg/ltaodataservice/BusStops?$top=3"
    @State private var acceptHeader = "application/json"
    @State private var result = "Enter request URL and tap Send Request."
    @State private var repository = BusStopRepository()
    @State private var topCount: Int = 3
    @State private var showDecoded: Bool = false
    @State private var busStops: [BusStop] = []

    var body: some View {
        List {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            SecureField("API Key", text: $apiKeyInput)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            Button("Save API Key") {
                saveAPIKey()
            }
            Stepper(value: $topCount, in: 1 ... 50, step: 1) {
                Text("Top: \(topCount)")
            }
            Toggle("Show decoded list", isOn: $showDecoded)
            TextField("Request URL", text: $requestURL)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            TextField("Accept Header (Optional)", text: $acceptHeader)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            Button(isLoading ? "Loading..." : "Send Request") {
                Task {
                    await sendRequest()
                }
            }
            .disabled(isLoading)
            if showDecoded {
                Section("Bus Stops") {
                    if busStops.isEmpty {
                        Text("No items. Tap Send Request.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(busStops, id: \.self) { stop in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(stop.description)
                                    .font(.body)
                                Text("\(stop.busStopCode) • \(stop.roadName)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } else {
                Text(result)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
        }
    }

    @MainActor
    private func sendRequest() async {
        isLoading = true
        defer { isLoading = false }
        do {
            if showDecoded {
                let decoded = try await repository.fetchBusStopsDecoded(top: topCount)
                busStops = decoded
                result = "Loaded \(decoded.count) bus stops."
            } else {
                let response = try await repository.fetchBusStops(top: topCount)
                result = "Status: \(response.statusCode)\n\(response.body)"
                busStops = []
            }
        } catch {
            result = error.localizedDescription
            busStops = []
        }
    }

    @MainActor
    private func saveAPIKey() {
        let key = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            result = "API Key is empty."
            return
        }
        do {
            try APIKeychain.shared.store(value: key, account: "public_api_key")
            result = "API Key saved to Keychain."
        } catch {
            result = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
