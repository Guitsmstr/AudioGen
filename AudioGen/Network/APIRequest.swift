//
//  APIRequest.swift
//  AudioGen
//
//  Created on November 19, 2025.
//

import Foundation

protocol APIRequest {
    associatedtype Response: Decodable
    
    var baseURL: String { get }
    var endpoint: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String]? { get }
    var body: Data? { get }
}

extension APIRequest {
    var baseURL: String {
        return APIConfiguration.openAIBaseURL
    }
    
    var headers: [String: String] {
        return [:]
    }
    
    var queryParameters: [String: String]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
}
