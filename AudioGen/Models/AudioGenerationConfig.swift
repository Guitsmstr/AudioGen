//
//  AudioGenerationConfig.swift
//  AudioGen
//
//  Created by Guillermo Vertel on 19/11/25.
//

import Foundation

/// Configuration for audio generation request
struct AudioGenerationConfig: Codable {
    let input: String
    let voice: String
    let model: String
    let speed: Double
    let responseFormat: String
    let instructions: String?
    
    init(
        input: String,
        voice: Voice = .default,
        model: String = "gpt-4o-mini-tts",
        speed: Double = 1.0,
        responseFormat: String = "mp3",
        instructions: String? = nil
    ) {
        self.input = input
        self.voice = voice.id
        self.model = model
        self.speed = speed
        self.responseFormat = responseFormat
        self.instructions = instructions?.isEmpty == false ? instructions : nil
    }
}

// MARK: - Validation

extension AudioGenerationConfig {
    enum ValidationError: LocalizedError {
        case emptyInput
        case inputTooLong
        case instructionsTooLong
        case invalidSpeed
        
        var errorDescription: String? {
            switch self {
            case .emptyInput:
                return "Input text cannot be empty"
            case .inputTooLong:
                return "Input text must be 4096 characters or less"
            case .instructionsTooLong:
                return "Instructions must be 1000 characters or less"
            case .invalidSpeed:
                return "Speed must be between 0.25 and 4.0"
            }
        }
    }
    
    func validate() -> Result<Void, ValidationError> {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.emptyInput)
        }
        
        guard input.count <= 4096 else {
            return .failure(.inputTooLong)
        }
        
        if let instructions = instructions, instructions.count > 1000 {
            return .failure(.instructionsTooLong)
        }
        
        guard speed >= 0.25 && speed <= 4.0 else {
            return .failure(.invalidSpeed)
        }
        
        return .success(())
    }
}
