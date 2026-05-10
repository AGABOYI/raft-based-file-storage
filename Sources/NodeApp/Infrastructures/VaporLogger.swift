//
//  File.swift
//  NodeAApp
//
//

import Foundation
import Vapor
import RaftSwiftPackage

struct VaporLogger: RaftLogHandler {

    let logger: Logger

    func info(_ message: String) {
        logger.info("\(message)")
    }

    func error(_ message: String) {
        logger.error("\(message)")
    }
    
    func warning(_ message: String) {
        logger.warning("\(message)")
    }
}
