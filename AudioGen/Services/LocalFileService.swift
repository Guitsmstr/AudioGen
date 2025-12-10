//
//  LocalFileService.swift
//  AudioGen
//
//  Created on December 7, 2025.
//

import Foundation
import CryptoKit
import OSLog

protocol LocalFileServiceProtocol {
    func saveGeneratedAudio(data: Data, config: AudioGenerationConfig) throws -> FileEntry
}

enum LocalFileError: LocalizedError {
    case outputDirectoryMissing
    case fileWriteFailed(Error)
    case indexUpdateFailed(Error)
    case encodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .outputDirectoryMissing:
            return "Output directory is missing or inaccessible."
        case .fileWriteFailed(let error):
            return "Failed to write audio file: \(error.localizedDescription)"
        case .indexUpdateFailed(let error):
            return "Failed to update index file: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Failed to encode file entry: \(error.localizedDescription)"
        }
    }
}

final class LocalFileService: LocalFileServiceProtocol {
    private let settingsManager: SettingsManager
    private let logger = Logger(subsystem: "com.audiogen", category: "LocalFileService")
    
    init(settingsManager: SettingsManager = .shared) {
        self.settingsManager = settingsManager
    }
    
    func saveGeneratedAudio(data: Data, config: AudioGenerationConfig) throws -> FileEntry {
        let configHash = computeConfigHash(config: config)
        let uniqueId = generateUniqueId()
        let sanitizedFilename = sanitizeFilename(config.input)
        let filename = "\(sanitizedFilename).\(config.responseFormat)"
        
        // File Operations
        let outputsFolder = settingsManager.outputsFolderURL
        let configFolder = outputsFolder.appendingPathComponent(configHash, isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: configFolder, withIntermediateDirectories: true)
            
            let fileURL = configFolder.appendingPathComponent("\(uniqueId).\(config.responseFormat)")
            try data.write(to: fileURL)
        } catch {
            throw LocalFileError.fileWriteFailed(error)
        }
        
        // Create FileEntry
        let relativePath = "\(configHash)/\(uniqueId).\(config.responseFormat)"
        let entry = FileEntry(
            id: uniqueId,
            filename: filename,
            path: relativePath,
            text: config.input,
            voice: config.voice,
            model: config.model,
            speed: config.speed,
            instructions: config.instructions,
            timestamp: Date()
        )
        
        // Index Management
        try updateIndex(with: entry)
        
        return entry
    }
    
    // MARK: - Private Helpers
    
    private func computeConfigHash(config: AudioGenerationConfig) -> String {
        let configString = "\(config.voice)-\(config.model)-\(config.speed)-\(config.responseFormat)"
        let inputData = Data(configString.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func generateUniqueId() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let random = Int.random(in: 0...0xFFFFFF)
        return String(format: "%x-%06x", timestamp, random)
    }
    
    private func sanitizeFilename(_ text: String) -> String {
        let maxLen = 50
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let sanitized = text.components(separatedBy: allowed.inverted).joined(separator: "-")
        let trimmed = sanitized.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return String(trimmed.prefix(maxLen))
    }
    
    private func updateIndex(with entry: FileEntry) throws {
        let indexURL = settingsManager.outputsFolderURL.appendingPathComponent("index.json")
        var indexFile: IndexFile
        
        do {
            if FileManager.default.fileExists(atPath: indexURL.path) {
                let data = try Data(contentsOf: indexURL)
                indexFile = try JSONDecoder().decode(IndexFile.self, from: data)
            } else {
                indexFile = IndexFile(version: "1.0", files: [])
            }
            
            indexFile.files.append(entry)
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(indexFile)
            try data.write(to: indexURL)
        } catch let error as EncodingError {
            throw LocalFileError.encodingFailed(error)
        } catch {
            throw LocalFileError.indexUpdateFailed(error)
        }
    }
}
