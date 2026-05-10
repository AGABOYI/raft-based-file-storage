import Vapor

struct NodeIDKey:StorageKey {
    typealias Value = String
}

public func configure(_ app: Application) async throws {

    // MARK: - Raft Node configuration (runtime identity)
    // Each running process represents one Raft node (A, B, C)
    // We read configuration from environment variables so the same binary
    // can run multiple nodes with different identities.

    let nodeId = Environment.get("NODE_ID") ?? ""
    let portString = Environment.get("PORT") ?? ""
    
    if nodeId.isEmpty {
        fatalError("Forgot to set NODE_ID")
    }
    guard let port = Int(portString) else {
        fatalError("Invalid PORT environment variable: \(portString)")
    }

    // MARK: - Configure HTTP server port
    // Each Raft node must run on a different port to simulate a cluster.

    app.http.server.configuration.port = port

    // MARK: - Store node identity in Application storage (optional pattern)
    // Useful if you need access to nodeId in routes/controllers later.

    app.storage[NodeIDKey.self] = nodeId

    // MARK: - Register routes (HTTP layer)
    // This sets up:
    // - /vote (Raft election RPC)
    // - /appendEntries (log replication RPC)
    // - /clientRequest (external API entry point)

    try routes(app)
}



