//
//  APIConfiguration.swift
//  AudioGen
//
//  Created on November 19, 2025.
//

import Foundation
import OSLog

struct APIConfiguration {
    private static let logger = Logger(subsystem: "com.audiogen", category: "Configuration")
    
    static let openAIBaseURL = "https://api.openai.com/v1"
    
    nonisolated static let timeout: TimeInterval = 60 // Longer timeout for audio generation
    
    // MARK: - Security Validation
    
    /// Validate URL scheme is http or https only
    static func hasValidScheme(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let scheme = url.scheme else {
            return false
        }
        
        return ["http", "https"].contains(scheme.lowercased())
    }
    
    /// Comprehensive URL validation
    static func isValidServerURL(_ urlString: String) -> Bool {
        guard hasValidScheme(urlString) else {
            logger.error("❌ Invalid URL scheme. Only http/https allowed.")
            return false
        }
        
        guard let url = URL(string: urlString),
              url.host != nil else {
            logger.error("❌ Invalid URL format.")
            return false
        }
        
        return true
    }
    
    // Rate limits (from API docs)
    nonisolated static let generalRateLimit = 100 // per 15 minutes
    nonisolated static let generationRateLimit = 20 // per 15 minutes
    nonisolated static let rateLimitWindow: TimeInterval = 15 * 60 // 15 minutes
}
