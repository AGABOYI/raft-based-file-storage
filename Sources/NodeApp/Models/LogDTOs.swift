//
//  File.swift
//  NodeAApp
//
//

import Foundation
import Vapor

struct LogRequestDTO: Content {
    let leaderId: String
    let term: Int
    let prefixLen: Int
    let prefixTerm: Int
    let commitLength: Int
    let suffix: [LogEntryDTO]
}

struct LogResponseDTO: Content {
    let term: Int
    let ack: Int
    let success: Bool
}

struct LogEntryDTO: Content {
    let index: Int
    let term: Int
    let command: FileCommandDTO
}
