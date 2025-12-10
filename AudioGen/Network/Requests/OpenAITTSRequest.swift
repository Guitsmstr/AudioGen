//
//  OpenAITTSRequest.swift
//  AudioGen
//
//  Created on December 2, 2025.
//

import Foundation

struct OpenAITTSRequest: APIRequest {
    // We use requestData for this request, so the Response type is not used for decoding.
    // However, we need to satisfy the protocol requirement.
    typealias Response = String 
    
    let apiKey: String
    let model: String
    let input: String
    let voice: String
    let responseFormat: String
    let speed: Double
    let instructions: String?
    
    var baseURL: String {
        return APIConfiguration.openAIBaseURL
    }
    
    var endpoint: String {
        return "/audio/speech"
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var headers: [String : String] {
        return [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
    }
    
    var body: Data? {
        var payload: [String: Any] = [
            "model": model,
            "input": input,
            "voice": voice,
            "response_format": responseFormat,
            "speed": speed
        ]
        
        if let instructions = instructions, !instructions.isEmpty {
            payload["instructions"] = instructions
        }
        
        return try? JSONSerialization.data(withJSONObject: payload)
    }
}
