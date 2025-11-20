//
//  User.swift
//  SocialNetworkApp
//
//  Created by Елена Хайрова on 19.11.2025.
//

import Foundation

struct User: Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String?
    let website: String?
    
    var avatarURL: URL? {
        return URL(string: "https://picsum.photos/40/40?random=\(id)")
    }
}
