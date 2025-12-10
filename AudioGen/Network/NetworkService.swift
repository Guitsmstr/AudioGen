//
//  NetworkService.swift
//  AudioGen
//
//  Created on November 19, 2025.
//

import Foundation
import OSLog

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var activeTasks: [UUID: URLSessionTask] = [:]
    private let logger = Logger(subsystem: "com.audiogen", category: "Network")
    
    init(timeout: TimeInterval = APIConfiguration.timeout) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        
        // Configure session with pinning delegate
        let delegate = NetworkSessionDelegate()
        self.session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        configureCoders()
    }
    
    private func configureCoders() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    func request<T: APIRequest>(_ request: T) async throws -> T.Response {
        let urlRequest = try buildURLRequest(from: request)
        
        // Log only method and host, not full URL (may contain sensitive query params)
        let host = urlRequest.url?.host ?? "unknown"
        logger.debug("📤 Request: \(urlRequest.httpMethod ?? "?", privacy: .public) to \(host, privacy: .public)")
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "Invalid response", code: -1))
            }
            
            logger.debug("📥 Response: \(httpResponse.statusCode)")
            
            try validateResponse(httpResponse, data: data)
            
            let decoded = try decoder.decode(T.Response.self, from: data)
            return decoded
            
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            throw mapURLError(error)
        } catch {
            if error is DecodingError {
                throw NetworkError.decodingError(error)
            }
            throw NetworkError.unknown(error)
        }
    }
    
    func requestData<T: APIRequest>(_ request: T) async throws -> Data {
        let urlRequest = try buildURLRequest(from: request)
        
        // Log only method and host, not full URL
        let host = urlRequest.url?.host ?? "unknown"
        logger.debug("📤 Request Data: \(urlRequest.httpMethod ?? "?", privacy: .public) to \(host, privacy: .public)")
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "Invalid response", code: -1))
            }
            
            logger.debug("📥 Response: \(httpResponse.statusCode, privacy: .public)")
            
            try validateResponse(httpResponse, data: data)
            
            return data
            
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            throw mapURLError(error)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    func downloadData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "Invalid response", code: -1))
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
    
    func cancelAllRequests() {
        session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }
    
    private func buildURLRequest<T: APIRequest>(from request: T) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: request.baseURL + request.endpoint) else {
            throw NetworkError.invalidURL
        }
        
        if let queryParams = request.queryParameters {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        
        // Set default headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add custom headers
        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return urlRequest
    }
    
    private func validateResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 400:
            // Try to decode error response
            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                if errorResponse.code == "VALIDATION_ERROR" {
                    let fields = errorResponse.details?.reduce(into: [String: String]()) { result, detail in
                        result[detail.field] = detail.message
                    } ?? [:]
                    throw NetworkError.validationError(fields: fields)
                }
                throw NetworkError.apiError(message: errorResponse.error, code: errorResponse.code)
            }
            throw NetworkError.serverError(statusCode: 400)
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 429:
            // Parse rate limit info from response
            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data),
               errorResponse.code == "RATE_LIMIT_EXCEEDED" {
                throw NetworkError.rateLimitExceeded(retryAfter: errorResponse.retryAfter)
            } else if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data),
                      errorResponse.code == "GENERATION_RATE_LIMIT_EXCEEDED" {
                throw NetworkError.generationRateLimitExceeded(retryAfter: errorResponse.retryAfter)
            }
            throw NetworkError.rateLimitExceeded(retryAfter: nil)
        case 500...599:
            throw NetworkError.serverError(statusCode: response.statusCode)
        default:
            throw NetworkError.serverError(statusCode: response.statusCode)
        }
    }
    
    private func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noConnection
        case .timedOut:
            return .timeout
        case .cancelled:
            return .cancelled
        case .cannotFindHost, .cannotConnectToHost:
            return .serverUnavailable
        default:
            return .unknown(error)
        }
    }
}

// MARK: - Error Response Models

private struct ErrorResponse: Decodable {
    let success: Bool
    let error: String
    let code: String?
    let details: [ErrorDetail]?
    let retryAfter: TimeInterval?
    
    enum CodingKeys: String, CodingKey {
        case success, error, code, details
        case retryAfter = "retry_after"
    }
}

private struct ErrorDetail: Decodable {
    let field: String
    let message: String
}
