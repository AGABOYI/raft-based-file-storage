import Vapor
import RaftSwiftPackage

func routes(_ app: Application) throws {

    // MARK: - Infrastructure layer (Vapor → Raft bridge)
    // These adapters isolate the Raft core from Vapor dependencies.

    let network = VaporNetworkClient(app: app)
    let logger = VaporLogger(logger: app.logger)

    // MARK: - Cluster configuration (network topology)
    // This defines how nodes discover and communicate with each other.
    // In production, this would be replaced by service discovery (Kubernetes, etcd, etc.)

    let cluster = Cluster(
        client: network,
        logger: logger,
        nodeMap: NodeRegistry.nodes
    )

    // MARK: - Raft node (core consensus logic)
    // Pure Raft implementation:
    // - No HTTP knowledge
    // - No Vapor dependency
    // - Only uses abstractions (NetworkClient, Logger)
    
    guard let nodeId = app.storage[NodeIDKey.self] else {
        fatalError("NODE_ID not configured in Application storage")
    }
    
    let node = Node(
        id: nodeId,
        nodes: NodeRegistry.allNodesIds,
        logger: logger,
        cluster: cluster
    )
    
    // 🔥 Start Raft system asynchronously
    Task {
        logger.info("⚙️ Booting Raft internal machinery for node \(nodeId)")
        await node.start()
        logger.info("✅ Raft node [\(nodeId)] fully started")
    }

    // MARK: - Controller (HTTP ↔ Raft translation layer)
    // Responsible for:
    // - decoding HTTP requests → domain models
    // - calling Raft logic
    // - mapping results → HTTP responses

    let controller = RaftController(node: node)

    // MARK: - Raft internal RPC endpoints
    // These endpoints are used ONLY for node-to-node communication.

    app.post("vote") { req async throws -> VoteResponseDTO in
        try await controller.voteRequest(req)
    }

    app.post("appendEntries") { req async throws -> LogResponseDTO in
        try await controller.appendEntriesRequest(req)
    }

    // MARK: - Client entry point (external API)
    // This is the ONLY endpoint exposed to external clients.
    // Clients send commands here, and Raft handles consensus internally.

    app.post("clientRequest") { req async throws -> Response in
        try await controller.clientRequest(req)
    }
}
