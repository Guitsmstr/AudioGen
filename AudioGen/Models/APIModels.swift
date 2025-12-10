//
//  APIModels.swift
//  AudioGen
//
//  Created on November 19, 2025.
//

import Foundation

// MARK: - Health Check

struct HealthCheckResponse: Decodable {
    let status: String
    let version: String
    let uptime: TimeInterval
    let timestamp: String
    
    var isHealthy: Bool {
        status == "ok"
    }
}

// MARK: - Voice List

struct VoiceListResponse: Decodable {
    let success: Bool
    let count: Int
    let voices: [VoiceAPIModel]
}

struct VoiceAPIModel: Decodable {
    let name: String
    
    func toDomainModel() -> Voice {
        // Map server voice names to full Voice model
        // Since server only returns name, we use static data for descriptions
        Voice.availableVoices.first(where: { $0.id == name }) ?? Voice(
            id: name,
            name: name.capitalized,
            description: ""
        )
    }
}

// MARK: - Audio Generation

struct GenerateAudioRequest: Encodable {
    let input: String
    let voice: String
    let model: String
    let speed: Double
    let responseFormat: String
    let instructions: String?
    
    enum CodingKeys: String, CodingKey {
        case input, voice, model, speed, instructions
        case responseFormat = "responseFormat"
    }
}

struct GenerateAudioResponse: Decodable {
    let success: Bool
    let id: String
    let filename: String
    let outputFile: String
    let fileSize: Int
    let fileSizeKB: Int
    let voice: String
    let model: String
    let configHash: String
    let duration: String
    
    enum CodingKeys: String, CodingKey {
        case success, id, filename, voice, model, duration
        case outputFile = "outputFile"
        case fileSize = "fileSize"
        case fileSizeKB = "fileSizeKB"
        case configHash = "configHash"
    }
}

// MARK: - Output List

struct OutputListResponse: Decodable {
    let success: Bool
    let count: Int
    let files: [OutputFile]
}

struct OutputFile: Decodable, Identifiable {
    let id: String
    let filename: String
    let path: String
    let text: String
    let fullText: String
    let voice: String
    let model: String
    let instructions: String
    let speed: Double
    let format: String
    let fileSize: Int
    let duration: String?
    let createdAt: String
    let configHash: String
    
    var createdDate: Date? {
        ISO8601DateFormatter().date(from: createdAt)
    }
}

// MARK: - Output Stats

struct OutputStatsResponse: Decodable {
    let success: Bool
    let stats: OutputStats
}

struct OutputStats: Decodable {
    let totalFiles: Int
    let totalSize: Int
    let totalSizeKB: Int
    let totalSizeMB: String
    let voiceCounts: [String: Int]
    let modelCounts: [String: Int]
}

// MARK: - File Details

struct FileDetailsResponse: Decodable {
    let success: Bool
    let file: OutputFile
}
