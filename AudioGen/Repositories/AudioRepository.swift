//
//  AudioRepository.swift
//  AudioGen
//
//  Created on November 19, 2025.
//

import Foundation
import OSLog

//
//  AudioRepository.swift
//  AudioGen
//
//  Created on November 19, 2025.
//

import Foundation
import OSLog
import CryptoKit

protocol AudioRepositoryProtocol {
    func generateAudio(config: AudioGenerationConfig) async -> Result<FileEntry, NetworkError>
    func cancelGeneration()
}

final class AudioRepository: AudioRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let settingsManager: SettingsManager
    private let rateLimiter: RateLimiter
    private let fileService: LocalFileServiceProtocol
    private let logger = Logger(subsystem: "com.audiogen", category: "AudioRepository")
    
    init(
        networkService: NetworkServiceProtocol,
        settingsManager: SettingsManager = .shared,
        rateLimiter: RateLimiter = RateLimiter(),
        fileService: LocalFileServiceProtocol = LocalFileService()
    ) {
        self.networkService = networkService
        self.settingsManager = settingsManager
        self.rateLimiter = rateLimiter
        self.fileService = fileService
    }
    
    func generateAudio(config: AudioGenerationConfig) async -> Result<FileEntry, NetworkError> {
        // Validate API Key
        guard !settingsManager.openAIKey.isEmpty else {
            return .failure(.unauthorized)
        }
        
        // Check rate limit
        let rateLimitCheck = await rateLimiter.canMakeGenerationRequest()
        guard rateLimitCheck.allowed else {
            return .failure(.generationRateLimitExceeded(retryAfter: rateLimitCheck.retryAfter))
        }
        
        do {
            // Execute OpenAITTSRequest
            let request = OpenAITTSRequest(
                apiKey: settingsManager.openAIKey,
                model: config.model,
                input: config.input,
                voice: config.voice,
                responseFormat: config.responseFormat,
                speed: config.speed,
                instructions: config.instructions
            )
            
            let audioData = try await networkService.requestData(request)
            
            // Record request
            await rateLimiter.recordGenerationRequest()
            
            // Delegate storage to LocalFileService
            let entry = try fileService.saveGeneratedAudio(data: audioData, config: config)
            
            return .success(entry)
            
        } catch let error as LocalFileError {
            return .failure(.fileError(error))
        } catch let error as NetworkError {
            return .failure(error)
        } catch {
            return .failure(.unknown(error))
        }
    }
    
    func cancelGeneration() {
        networkService.cancelAllRequests()
    }
}

