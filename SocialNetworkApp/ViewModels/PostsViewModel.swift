//
//  PostsViewModel.swift
//  SocialNetworkApp
//
//  Created by Елена Хайрова on 19.11.2025.
//
import UIKit

class PostsViewModel {
    private let networkManager = NetworkManager()
    private let coreDataManager = CoreDataManager.shared
    
    var posts: [Post] = []
    var onPostsUpdated: (() -> Void)?
    var onPostUpdated: ((Int) -> Void)?
    
    private var currentPage = 1
    private let postsPerPage = 20
    private var isLoading = false
    private var hasMorePosts = true
    
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    func loadPosts() {
        let cachedPosts = coreDataManager.fetchPosts()
        if !cachedPosts.isEmpty && currentPage == 1 {
            self.posts = cachedPosts
            self.onPostsUpdated?()
        }
        
        currentPage = 1
        hasMorePosts = true
        loadMorePosts()
    }

    func loadMorePosts() {
        guard !isLoading && hasMorePosts else { return }
        
        isLoading = true
        onLoadingStateChanged?(true)
        
        networkManager.fetchPosts(page: currentPage, limit: postsPerPage) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.onLoadingStateChanged?(false)
                
                switch result {
                case .success(let newPosts):
                    if newPosts.isEmpty {
                        self.hasMorePosts = false
                        return
                    }
                    
                    self.coreDataManager.savePosts(newPosts)
                    
                    if self.currentPage == 1 {
                        self.posts = newPosts
                    } else {
                        self.posts.append(contentsOf: newPosts)
                    }
                    
                    self.currentPage += 1
                    self.onPostsUpdated?()
                    
                case .failure(let error):
                    print("Network error: \(error)")
                }
            }
        }
    }
    
    func getCellViewModel(at index: Int) -> PostCellViewModel {
        let post = posts[index]
        let isLiked = isPostLiked(post.id)
        return PostCellViewModel(post: post, isLiked: isLiked)
    }
    
    func toggleLike(for postId: Int) {
        coreDataManager.toggleLike(for: postId)
        
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            onPostUpdated?(index)
        }
    }
    
    func isPostLiked(_ postId: Int) -> Bool {
        return coreDataManager.getLikeStatus(for: postId)
    }
}
