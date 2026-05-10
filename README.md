---

# 🧠 Distributed File Storage System Using Raft in Swift

⚡ Raft Consensus • Distributed File Storage System • Swift Concurrency • Vapor Backend

A production-inspired distributed file storage system built in swift using **Raft Consensus Algorithm**, implementing with **Vapor for networking** and **Swift Concurrency (`async/await` + `actors`)** for safe distributed coordination.

This project demonstrates how a cluster of independent Swift services can achieve **consistency, fault tolerance, and leader election** in a distributed system.

Unlike most Raft implementations found in Go or Java, this project explores Swift as a **serious backend and distributed systems language**, using modern concurrency primitives as the core execution model.

---

## 📌 What This Project Is

This is a **multi-node distributed file storage system simulation**, where each node runs independently and coordinates using the Raft consensus algorithm.

Each node behaves like a real participant in a distributed cluster, implementing the full Raft lifecycle:

* 🗳️ Leader election (majority-based consensus)
* 💓 Heartbeat mechanism (leader liveness & stability)
* 📦 Log replication (state consistency across nodes)
* 💾 Persistent state (crash recovery support)
* 🔁 Conflict resolution (log repair & reconciliation)

---

## 🧠 Core Idea (Simple View)

Think of Raft as a system where multiple servers must always agree on **one single source of truth**.

* One node becomes the **Leader**
* The Leader handles all client requests
* It replicates updates to Followers
* If the Leader fails → a new election starts automatically

> Even under failures, the cluster eventually converges to the same state.

---

## 🏗️ Architecture Overview

```
                ┌────────────────────┐
                │   Vapor Server     │
                │ (HTTP Interface)   │
                └─────────┬──────────┘
                          │
                          ▼
                ┌────────────────────┐
                │     Cluster        │
                │ (RPC Abstraction)  │
                └─────────┬──────────┘
                          │
                          ▼
                ┌────────────────────┐
                │       Node         │
                │ (Raft Core Logic)  │
                └─────────┬──────────┘
                          │
                          ▼
                ┌────────────────────┐
                │   StateMachine     │
                │ (Applies Commands) │
                └─────────┬──────────┘
                          │
                          ▼
                ┌────────────────────┐
                │ Persistent Storage │
                │   (JSON logs)      │
                └────────────────────┘
```

---

## 🔹 Key Components

* **Node** → Implements Raft protocol (leader election, replication, coordination)
* **Cluster** → Handles inter-node communication (RPC abstraction layer)
* **StateMachine** → Applies committed log entries (file operations)
* **Models** → Raft protocol messages (RequestVote, AppendEntries, etc.)
* **Networking Layer** → Abstract HTTP client (decoupled from Vapor)

---

## ⚙️ Features Implemented

### 🗳️ Leader Election

Nodes start as followers and trigger elections using randomized timeouts.
A leader is elected after receiving a **majority vote**.

---

### 💓 Heartbeats

The leader periodically sends heartbeat messages to:

* Maintain authority
* Prevent new elections
* Trigger replication cycles

---

### 📦 Log Replication (File Operation Replication)

Client commands follow a strict flow:

1. Appended to leader log
2. Replicated to followers
3. Committed after majority agreement

---

### 💾 Persistent State

Each node persists critical Raft state:

* current term
* voted candidate
* log entries
* commit index

Enables safe recovery after crashes.

---

### 🔁 Fault Recovery

Nodes can:

* crash
* restart
* restore state from disk

…and rejoin the cluster without breaking consensus.

---

## 🧪 Running the System

```bash
NODE_ID=A PORT=8080 swift run
NODE_ID=B PORT=8081 swift run
NODE_ID=C PORT=8082 swift run
```

---

## 📡 API Endpoints

### Internal Raft RPC (Node-to-Node)

* `POST /vote` → RequestVote RPC
* `POST /appendEntries` → Log replication RPC

### External API (Client)

* `POST /clientRequest` → Submit file system operations (create, delete, update files in the distributed storage system)

---

## 🧱 Example Commands

```swift
.createFile(path: "test.txt", data: ...)
.deleteFile(path: "test.txt")
```

---

## 🧠 What Makes This Project Stand Out

This project is not a Raft explanation — it is a **full distributed file storage system built on top of the Raft consensus algorithm**, demonstrating how consistency and fault tolerance can be achieved across multiple Swift services.

What makes it unique is not *what Raft is*, but **how it is implemented in Swift using modern concurrency and backend tooling**.

---

### ⚡ Swift as a Distributed Systems Language

This project treats Swift as a first-class backend + systems programming language:

* Built entirely with **Swift Concurrency (`async/await`)**
* Heavy use of **`actor` isolation for safe distributed state**
* Structured concurrency models:

  * leader election loops
  * heartbeat scheduling
  * log replication pipelines
* `Task`-based scheduling replaces traditional threading/timer systems

No external concurrency frameworks — only Swift’s native model.

---

### 🧩 Actor-Based Cluster Coordination

Each node is an isolated concurrent unit modeled using `actor`:

* Guarantees **data-race-free state transitions**
* Encapsulates:

  * election state
  * replication state
  * leadership transitions
* Ensures safe concurrent RPC handling across nodes

---

### 🌐 Swift-Native Backend with Vapor

Instead of Go/Java/Node.js, this system uses:

* Vapor as the HTTP transport layer
* Pure Swift-based RPC communication between nodes
* Clear separation:

  * distributed logic (Swift actors)
  * networking layer (Vapor HTTP)

This demonstrates Swift as a **full backend + distributed systems stack**.

---

### 🔁 Fully Async Distributed Coordination

The system uses Swift’s async runtime for coordination:

* `async/await` for non-blocking RPC communication
* `Task {}` for concurrent fan-out across nodes
* cancellation-aware loops for:

  * heartbeats
  * elections
  * replication retries

This models a real asynchronous distributed runtime in Swift.

---

### 💾 Fault Tolerance with Persistence

Each node persists Raft state locally:

* current term
* voted candidate
* replicated log
* commit index

Enables:

* crash recovery
* safe restart
* cluster rejoining without inconsistency

---

### 🏗 Modular Systems Architecture

The project follows production-style separation:

* **Core** → distributed runtime (Node, Cluster, StateMachine)
* **Models** → protocol definitions
* **Networking** → HTTP transport abstraction
* **Logging** → structured logging layer
* **Errors** → domain-specific failures

---

## 📁 Project Structure

```
Sources/RaftSwiftPackage/

Core/
Errors/
Logging/
Models/
Networking/
```

---

## 🚀 Future Improvements

* Dynamic cluster membership
* Log snapshots & compaction
* Optional: Replace HTTP with gRPC for production-grade RPC performance
* Kubernetes/Docker deployment
* Observability dashboard

---

## 📚 References

* “In Search of an Understandable Consensus Algorithm” — Diego Ongaro & John Ousterhout
---
