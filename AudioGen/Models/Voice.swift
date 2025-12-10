//
//  Voice.swift
//  AudioGen
//
//  Created by Guillermo Vertel on 19/11/25.
//

import Foundation

/// Represents an available voice for text-to-speech generation
struct Voice: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String
    
    init(id: String, name: String, description: String = "") {
        self.id = id
        self.name = name
        self.description = description
    }
}

// MARK: - Available Voices

extension Voice {
    /// All available voices from the OpenAI TTS API
    static let availableVoices: [Voice] = [
        Voice(
            id: "alloy",
            name: "Alloy",
            description: "Neutral and balanced"
        ),
        Voice(
            id: "echo",
            name: "Echo",
            description: "Clear and articulate"
        ),
        Voice(
            id: "fable",
            name: "Fable",
            description: "Warm and expressive"
        ),
        Voice(
            id: "onyx",
            name: "Onyx",
            description: "Deep and authoritative"
        ),
        Voice(
            id: "nova",
            name: "Nova",
            description: "Energetic and bright"
        ),
        Voice(
            id: "shimmer",
            name: "Shimmer",
            description: "Soft and gentle"
        ),
        Voice(
            id: "ash",
            name: "Ash",
            description: "Natural and conversational"
        )
    ]
    
    /// Default voice (Ash as per API docs)
    static let `default`: Voice = availableVoices.first(where: { $0.id == "ash" })!
}
