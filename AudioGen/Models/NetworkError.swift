//
//  NetworkError.swift
//  AudioGen
//
//  Created on November 19, 2025.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case serverUnavailable
    case noConnection
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int)
    case decodingError(Error)
    case encodingError(Error)
    case rateLimitExceeded(retryAfter: TimeInterval?)
    case generationRateLimitExceeded(retryAfter: TimeInterval?)
    case validationError(fields: [String: String])
    case apiError(message: String, code: String?)
    case timeout
    case cancelled
    case fileError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL"
        case .serverUnavailable:
            return "TTS server is not running. Please start the server."
        case .noConnection:
            return "No internet connection"
        case .unauthorized:
            return "Authentication failed"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError(let code):
            return "Server error (code: \(code))"
        case .decodingError:
            return "Failed to parse server response"
        case .encodingError:
            return "Failed to encode request"
        case .rateLimitExceeded(let retryAfter):
            if let retry = retryAfter {
                return "Rate limit exceeded. Try again in \(Int(retry)) seconds."
            }
            return "Rate limit exceeded. Please wait before trying again."
        case .generationRateLimitExceeded(let retryAfter):
            if let retry = retryAfter {
                return "Generation rate limit exceeded. Try again in \(Int(retry)) seconds."
            }
            return "Generation rate limit exceeded. Please wait before trying again."
        case .validationError(let fields):
            return "Validation error: \(fields.values.joined(separator: ", "))"
        case .apiError(let message, _):
            return message
        case .timeout:
            return "Request timed out"
        case .cancelled:
            return "Request was cancelled"
        case .fileError(let error):
            return error.localizedDescription
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
