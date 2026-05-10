//
//  File.swift
//  NodeAApp
//
//

import Foundation

struct NodeRegistry {

    static let nodes: [String: String] = [
        "A": "http://localhost:8080",
        "B": "http://localhost:8081",
        "C": "http://localhost:8082"
    ]
    
    static var allNodesIds:[String] {
        Array(nodes.keys)
    }

    static func url(for node: String) -> String? {
        nodes[node]
    }
    
}


