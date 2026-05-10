//
//  File.swift
//  NodeAApp
//
//

import Foundation
import Vapor

struct RequestVoteDTO: Content {
    let candidateId: String
    let term: Int
    let lastLogIndex: Int
    let lastLogTerm: Int
}

struct VoteResponseDTO: Content {
    let term: Int
    let granted: Bool
}
