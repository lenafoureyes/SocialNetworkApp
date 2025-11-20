//
//  CoreDataManager.swift
//  SocialNetworkApp
//
//  Created by Елена Хайрова on 19.11.2025.
//
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "SocialNetworkApp")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("CoreData load error: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    func savePosts(_ posts: [Post]) {
        let context = persistentContainer.viewContext
        
        for post in posts {
            let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", post.id)
            
            do {
                let existingPosts = try context.fetch(request)
                let postEntity: PostEntity
                
                if let existingPost = existingPosts.first {
                    postEntity = existingPost
                } else {
                    postEntity = PostEntity(context: context)
                    postEntity.id = Int32(post.id)
                    postEntity.isLiked = false
                }
                
                postEntity.userId = Int32(post.userId)
                postEntity.title = post.title
                postEntity.body = post.body
                
            } catch {
                print("Error checking existing post: \(error)")
            }
        }
        
        saveContext()
    }

    func fetchPosts() -> [Post] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        do {
            let postEntities = try context.fetch(request)
            let posts = postEntities.map { postEntity in
                Post(
                    userId: Int(postEntity.userId),
                    id: Int(postEntity.id),
                    title: postEntity.title ?? "",
                    body: postEntity.body ?? ""
                )
            }
            return posts
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    func toggleLike(for postId: Int) {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", postId)
        
        do {
            let posts = try context.fetch(request)
            if let post = posts.first {
                post.isLiked.toggle()
                saveContext()
            }
        } catch {
            print("Toggle like error: \(error)")
        }
    }

    func getLikeStatus(for postId: Int) -> Bool {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", postId)
        
        do {
            let posts = try context.fetch(request)
            return posts.first?.isLiked ?? false
        } catch {
            print("Get like status error: \(error)")
            return false
        }
    }
}
