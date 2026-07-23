//  ClientTests.swift
//
//  Copyright © 2026 Aung Ko Min.
//

@testable import Client
import Testing
import Foundation

final class MockNetworkClient: NetworkClientProtocol {
    var mockResponse: Any?
    var mockError: Error?

    func perform<T: Decodable>(_: URLRequest) throws -> T {
        if let mockError {
            throw mockError
        }
        guard let response = mockResponse as? T else {
            throw NetworkError.noData
        }
        return response
    }

    func perform(_: URLRequest) throws {
        if let mockError {
            throw mockError
        }
    }

    func performAndDecode<T: Decodable, R: NetworkRequest>(_: R) throws -> T where R.Response == T {
        if let mockError {
            throw mockError
        }
        guard let response = mockResponse as? T else {
            throw NetworkError.noData
        }
        return response
    }
}

struct UserRepositoryTests {
    @Test func getUserSuccess() async throws {
        let mockNetworkClient = MockNetworkClient()
        let repository = UserRepository(networkClient: mockNetworkClient)
        let expectedUser = User(
            id: 1,
            name: "John Doe",
            email: "john@example.com",
            createdAt: Date(),
            updatedAt: Date()
        )
        mockNetworkClient.mockResponse = expectedUser

        let user = try await repository.getUser(id: 1)

        #expect(user.id == expectedUser.id)
        #expect(user.name == expectedUser.name)
        #expect(user.email == expectedUser.email)
    }

    @Test func getUserFailureNotFound() async {
        let mockNetworkClient = MockNetworkClient()
        let repository = UserRepository(networkClient: mockNetworkClient)
        mockNetworkClient.mockError = NetworkError.notFound

        await #expect(throws: NetworkError.self) {
            _ = try await repository.getUser(id: 1)
        }
    }
}
