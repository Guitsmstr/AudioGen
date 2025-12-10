//
//  VoiceRepository.swift
//  AudioGen
//
//  Created on November 19, 2025.
//

import Foundation

protocol VoiceRepositoryProtocol {
    func checkServerHealth() async -> Result<Bool, NetworkError>
    func fetchVoices(forceFresh: Bool) async -> Result<[Voice], NetworkError>
}

final class VoiceRepository: VoiceRepositoryProtocol {
    private var cachedVoices: [Voice]?
    private var cacheTimestamp: Date?
    private let cacheTTL: TimeInterval = 5 * 60 // 5 minutes
    
    init() {}
    
    func checkServerHealth() async -> Result<Bool, NetworkError> {
        // Since we are now serverless (direct to OpenAI), we consider the "server" always healthy
        // In a real app, we might check for internet connectivity here.
        return .success(true)
    }
    
    func fetchVoices(forceFresh: Bool = false) async -> Result<[Voice], NetworkError> {
        // OpenAI voices are static, so we return the local list.
        // We simulate an async operation to match the protocol.
        return .success(Voice.availableVoices)
    }
}
