//
//  File.swift
//  NodeAApp
//
//

import Foundation
import Vapor

enum FileCommandDTO: CustomStringConvertible, Content {

    case createFile(path: String, data: Data)
    case deleteFile(path: String)

    var description: String {
        switch self {
        case .createFile(let path, _):
            return "createFile(\(path))"
        case .deleteFile(let path):
            return "deleteFile(\(path))"
        }
    }
}
