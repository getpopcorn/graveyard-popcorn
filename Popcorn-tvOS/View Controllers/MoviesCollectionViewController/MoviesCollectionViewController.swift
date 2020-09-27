//
//  MoviesCollectionViewController.swift
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 30/6/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit_tvOS
import UIKit

class MoviesCollectionViewController : UICollectionViewController {
    var movies = [Movie]()
    var error: NSError?
    
    var isLoading = false
    var paginated = true
    var hasNextPage = false
    var currentPage = 1
    var loadCompletePage = 1
    
    
    var currentFilter: MovieManager.Filters = .trending {
        didSet {
            movies = []
            self.didRefresh(collectionView: self.collectionView)
            load(page: 1)
        }
    }
    
    var currentGenre: NetworkManager.Genres = .all {
        didSet {
            movies = []
            self.didRefresh(collectionView: self.collectionView)
            load(page: 1)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        title = "Movies"
        navigationController?.navigationBar.isTranslucent = false
        
        
        navigationItem.setRightBarButtonItems([
            UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(movieGenres(sender:))),
            UIBarButtonItem(image: UIImage(systemName: "line.horizontal.2.decrease.circle"), style: .plain, target: self, action: #selector(movieFilters(sender:)))
        ], animated: true)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MediaCell.self, forCellWithReuseIdentifier: "MediaCell")
        
        
        load(page: 1)
    }
    
    
    func didRefresh(collectionView: UICollectionView) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    
    @objc func movieGenres(sender: UIBarButtonItem) {
        AlertHelper.showGenre(current: currentGenre) { (genre) in
            self.currentGenre = genre
        }
    }
    
    
    @objc func movieFilters(sender: UIBarButtonItem) {
        AlertHelper.showMovieFilter(current: currentFilter) { (filter) in
            self.currentFilter = filter
        }
    }
    
    
    func load(page: Int) {
        guard !isLoading else {
            return
        }
        
        
        isLoading = true
        hasNextPage = false
        PopcornKit_tvOS.loadMovies(page, filterBy: currentFilter, genre: currentGenre) { [unowned self] (movies, error) in
            self.isLoading = false
            
            guard let movies = movies else {
                self.error = error;
                self.didRefresh(collectionView: self.collectionView)
                return
            }
            
            
            if self.movies.count > 0 {
                self.movies += movies
            } else {
                self.movies = movies
            }
            self.movies.unique()
            
            
            if movies.isEmpty {
                self.collectionView?.contentInset.bottom = self.tabBarController?.tabBar.frame.height ?? 0
            } else {
                self.hasNextPage = true
            }
            
            
            self.didRefresh(collectionView: self.collectionView)
            self.setNeedsFocusUpdate()
        }
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = collectionView, scrollView == collectionView, paginated else { return }
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        let height = scrollView.contentSize.height
        let reloadDistance: CGFloat = 10
        
        
        if y > height + reloadDistance && !isLoading && hasNextPage {
            currentPage += 1
            load(page: currentPage)
        }
    }
}


extension MoviesCollectionViewController : UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let mediaCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCell
        mediaCell.configureCellWith(movies[indexPath.item])
        return mediaCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCell
        cell.startSelectAnimation()
        
        
        let viewController = LoadingViewController()
        viewController.media = movies[indexPath.item]
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 64
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCells: CGFloat = 10
        let width = collectionView.bounds.width
        
        let cellWidth = width/numberOfCells
        
        return CGSize(width: (cellWidth-10), height: (cellWidth-10)*1.65)
    }
}
