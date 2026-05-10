//
//  File.swift
//  NodeAApp
//
//

import Vapor
import RaftSwiftPackage

final class RaftController: Sendable {

    private let node: Node

    init(node: Node) {
        self.node = node
    }

    // MARK: - Vote
    func voteRequest(_ req: Request) async throws -> VoteResponseDTO {
        
        do {
            let message = try req.content.decode(RequestVoteDTO.self)
            
            let result =  await node.onReceiveVoteRequest(
                candidateId: message.candidateId,
                term: message.term,
                lastLogIndex: message.lastLogIndex,
                lastLogTerm: message.lastLogTerm
            )
            
            return VoteResponseDTO(
                term: result.term,
                granted: result.granted
            )
        } catch is DecodingError {
            req.logger.error("❌ Invalid RequestVote payload")
            throw Abort(.badRequest, reason: "Invalid vote request payload")
        }
        catch {
            req.logger.error("❌ Internal vote error: \(error)")
            throw Abort(.internalServerError)
        }
        
    }
    
    // MARK: - replicate logs
    
    func appendEntriesRequest(_ req:Request) async throws -> LogResponseDTO {
        
        do {
            let logRequestPayload = try req.content.decode(LogRequestDTO.self)
            let logRequest = LogRequest(
                    leaderId: logRequestPayload.leaderId,
                    term: logRequestPayload.term,
                    prefixLen: logRequestPayload.prefixLen,
                    prefixTerm: logRequestPayload.prefixTerm,
                    commitLength: logRequestPayload.commitLength,
                    suffix: logRequestPayload.suffix.map {
                        RaftModelsMapper.toLogEntry($0)
                    }
                )
            let result = await node.onReceiveLogRequest(logRequest)
            return LogResponseDTO(
                term: result.term,
                ack: result.ack,
                success: result.success
            )
        } catch is DecodingError {
            req.logger.error("❌ Invalid AppendEntries payload")
            throw Abort(.badRequest, reason: "Invalid appendEntries request payload")

        } catch {
            req.logger.error("❌ Internal appendEntries error: \(error)")
            throw Abort(.internalServerError)
        }
    }
    
    // MARK: - handle client request
    func clientRequest(_ req: Request) async throws -> Response {
        do {
            let command = try req.content.decode(FileCommandDTO.self)
            let model = RaftModelsMapper.toFileCommand(command)
            try await node.onClientRequest(model)

            return Response(status: .ok)
        }
        // ❌ bad JSON
        catch is DecodingError {
            req.logger.error("❌ Invalid FileCommand payload")
            throw Abort(.badRequest, reason: "Invalid request format")
        }
        // ❌ Node is not leader → redirect client
        catch RaftError.notLeader(let leaderId) {
            req.logger.warning("⚠️ Not leader → redirecting to \(leaderId ?? "unknown")")
            guard let leaderId,
                     let url = NodeRegistry.url(for: leaderId) else {
                throw RaftError.noLeaderAvailable
               }

               throw Abort(
                   .temporaryRedirect,
                   headers: ["Location": "\(url)/clientRequest"]
               )
        }
        // ❌ No leader yet in cluster
        catch RaftError.noLeaderAvailable {
            req.logger.warning("⚠️ No leader available")
            throw Abort(.serviceUnavailable, reason: "Cluster has no leader yet")
        }

            // ❌ Node is dead
        catch RaftError.nodeDead {
            req.logger.error("💀 Node is dead")
            throw Abort(.serviceUnavailable, reason: "Node unavailable")
        }

            // ❌ unexpected bug
        catch {
            req.logger.error("❌ Internal error: \(error)")
            throw Abort(.internalServerError)
        }

        
    }
}
