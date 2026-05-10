//
//  File.swift
//  NodeAApp
//
//

import Foundation
import RaftSwiftPackage

struct RaftModelsMapper {
    
    static func toLogEntry (_ dto:LogEntryDTO) -> LogEntry {
        return LogEntry(
            index: dto.index,
            term: dto.term,
            command:toFileCommand(dto.command)
        )
    }
    
    static func toFileCommand(_ dto: FileCommandDTO) -> FileCommand {
        switch dto {
        case .createFile(let path, let data):
            return .createFile(path: path, data: data)
            
        case .deleteFile(let path):
            return .deleteFile(path: path)
        }
    }
}

