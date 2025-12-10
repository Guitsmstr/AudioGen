//
//  RateLimiter.swift
//  AudioGen
//
//  Created on November 19, 2025.
//

import Foundation

actor RateLimiter {
    private var generalRequests: [Date] = []
    private var generationRequests: [Date] = []
    
    private let generalLimit = APIConfiguration.generalRateLimit
    private let generationLimit = APIConfiguration.generationRateLimit
    private let windowDuration = APIConfiguration.rateLimitWindow
    
    func canMakeGeneralRequest() -> (allowed: Bool, retryAfter: TimeInterval?) {
        cleanOldRequests()
        
        if generalRequests.count < generalLimit {
            return (true, nil)
        }
        
        if let oldest = generalRequests.first {
            let retryAfter = windowDuration - Date().timeIntervalSince(oldest)
            return (false, max(0, retryAfter))
        }
        
        return (true, nil)
    }
    
    func canMakeGenerationRequest() -> (allowed: Bool, retryAfter: TimeInterval?) {
        cleanOldRequests()
        
        // Check both general and generation limits
        let generalCheck = canMakeGeneralRequest()
        guard generalCheck.allowed else {
            return generalCheck
        }
        
        if generationRequests.count < generationLimit {
            return (true, nil)
        }
        
        if let oldest = generationRequests.first {
            let retryAfter = windowDuration - Date().timeIntervalSince(oldest)
            return (false, max(0, retryAfter))
        }
        
        return (true, nil)
    }
    
    func recordGeneralRequest() {
        cleanOldRequests()
        generalRequests.append(Date())
    }
    
    func recordGenerationRequest() {
        cleanOldRequests()
        generalRequests.append(Date())
        generationRequests.append(Date())
    }
    
    private func cleanOldRequests() {
        let cutoff = Date().addingTimeInterval(-windowDuration)
        generalRequests.removeAll { $0 < cutoff }
        generationRequests.removeAll { $0 < cutoff }
    }
    
    func reset() {
        generalRequests.removeAll()
        generationRequests.removeAll()
    }
}
