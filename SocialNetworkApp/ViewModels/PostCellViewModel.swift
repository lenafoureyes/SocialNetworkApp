//
//  PostCellViewModel.swift
//  SocialNetworkApp
//
//  Created by Елена Хайрова on 19.11.2025.
//

import Foundation

class PostCellViewModel {
    let postId: Int
    let title: String
    let body: String
    let userId: Int
    let avatarURL: URL?
    var isLiked: Bool
    
    init(post: Post, isLiked: Bool) {
        self.postId = post.id
        self.title = post.title
        self.body = post.body
        self.userId = post.userId
        self.isLiked = isLiked
        self.avatarURL = URL(string: "https://picsum.photos/40/40?random=\(post.userId)")
    }
    
    var formattedTitle: String {
        return title.capitalized
    }
    
    var previewBody: String {
        return String(body.prefix(100)) + (body.count > 100 ? "..." : "")
    }
}
