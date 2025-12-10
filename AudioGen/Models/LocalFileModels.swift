//
//  LocalFileModels.swift
//  AudioGen
//
//  Created on December 2, 2025.
//

import Foundation

struct FileEntry: Codable, Identifiable {
    let id: String
    let filename: String
    let path: String
    let text: String
    let voice: String
    let model: String
    let speed: Double
    let instructions: String?
    let timestamp: Date
    
    // Helper to create full URL
    func url(relativeTo baseURL: URL) -> URL {
        return baseURL.appendingPathComponent(path)
    }
}

struct IndexFile: Codable {
    let version: String
    var files: [FileEntry]
}
