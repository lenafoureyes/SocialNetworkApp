//
//  NetworkManager.swift
//  SocialNetworkApp
//
//  Created by Елена Хайрова on 19.11.2025.
//

import Foundation

class NetworkManager {
    private let baseURL = "https://jsonplaceholder.typicode.com"
    
    func fetchPosts(page: Int, limit: Int = 20, completion: @escaping (Result<[Post], Error>) -> Void) {
        let urlString = "\(baseURL)/posts?_page=\(page)&_limit=\(limit)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                completion(.success(posts))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
}
