//
//  PostTableViewCell.swift
//  SocialNetworkApp
//
//  Created by Елена Хайрова on 19.11.2025.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    static let identifier = "PostTableViewCell"
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .red
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(likeButton)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            likeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 30),
            likeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false

        if let textLabel = textLabel, let detailTextLabel = detailTextLabel {
            NSLayoutConstraint.activate([
                textLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
                textLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -8),
                textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                
                detailTextLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
                detailTextLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -8),
                detailTextLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 4),
                detailTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
            ])
        }
        
        textLabel?.numberOfLines = 0
        detailTextLabel?.numberOfLines = 0
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func likeButtonTapped() {
        likeButton.isSelected.toggle()
        onLikeTapped?(postId)
    }
    
    var onLikeTapped: ((Int) -> Void)?
    private var postId: Int = 0
    
    func configure(with viewModel: PostCellViewModel, onLikeTapped: @escaping (Int) -> Void) {
        textLabel?.text = viewModel.formattedTitle
        detailTextLabel?.text = viewModel.previewBody
        likeButton.isSelected = viewModel.isLiked
        
        self.postId = viewModel.postId
        self.onLikeTapped = onLikeTapped
        loadAvatar(for: viewModel.userId)
    }
    
    private func loadAvatar(for userId: Int) {
        let imageUrl = "https://picsum.photos/40/40?random=\(userId)"
        
        if let cachedImage = ImageCacheManager.shared.getImage(for: imageUrl) {
            avatarImageView.image = cachedImage
            return
        }
        
        guard let url = URL(string: imageUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else { return }
            
            ImageCacheManager.shared.setImage(image, for: imageUrl)
            
            DispatchQueue.main.async {
                if self.postId == userId {
                    self.avatarImageView.image = image
                }
            }
        }.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
