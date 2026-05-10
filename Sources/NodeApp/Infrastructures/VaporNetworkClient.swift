//
//  File.swift
//  NodeAApp
//
//

import Foundation
import Vapor
import RaftSwiftPackage

struct VaporNetworkClient: RaftNetworkClient {

    let app: Application

    func post<T: Codable, R: Codable>(
        url: String,
        body: T,
        responseType: R.Type
    ) async throws -> R {

        let res = try await app.client.post(URI(string: url)) { req in
            let data = try JSONEncoder().encode(body)
            req.body = .init(data: data)
            req.headers.contentType = .json
        }

        return try res.content.decode(R.self)
    }
}
