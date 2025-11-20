//
//  PostsViewController.swift
//  SocialNetworkApp
//
//  Created by Елена Хайрова on 19.11.2025.
//

import UIKit

class PostsViewController: UIViewController {
    private let viewModel = PostsViewModel()
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadData()
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        title = "Posts"
        view.backgroundColor = .white
        
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
        
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
       
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        spinner.hidesWhenStopped = true
        tableView.tableFooterView = spinner
    }
    
    private func setupBindings() {
        viewModel.onPostsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.onPostUpdated = { [weak self] index in
            let indexPath = IndexPath(row: index, section: 0)
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            if isLoading {
                (self?.tableView.tableFooterView as? UIActivityIndicatorView)?.startAnimating()
            } else {
                (self?.tableView.tableFooterView as? UIActivityIndicatorView)?.stopAnimating()
            }
        }
    }
    
    private func loadData() {
        viewModel.loadPosts()
    }
    
    @objc private func refreshData() {
        viewModel.loadPosts()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension PostsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        
        let cellViewModel = viewModel.getCellViewModel(at: indexPath.row)
        
        cell.configure(with: cellViewModel) { [weak self] postId in
            self?.viewModel.toggleLike(for: postId)
        }
        
        return cell
    }
}

extension PostsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row >= lastRowIndex - 3 {
            viewModel.loadMorePosts()
        }
    }
}
