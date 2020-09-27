//
//  MainMediaCollectionViewController.swift
//  Popcorn-iOS
//
//  Created by Antique on 14/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import PopcornTorrent
import UIKit

class MainMediaCollectionViewController : UICollectionViewController {
    var new = [Media]()
    var allMovies = [Movie]()
    var allShows = [Show]()
    var currentType: Int = 0 // 0 = movies, 1 = shows
    
    var isMovieLoading = false
    var isShowLoading = false
    var moviePaginated = true
    var showPaginated = true
    var movieHasNextPage = false
    var showHasNextPage = false
    var currentMoviePage = 1
    var currentShowPage = 1
    
    
    var isSearching = false
    var searched = [Media]()
    
    
    var currentMovieGenre: NetworkManager.MovieGenres = .all {
        didSet {
            allMovies = []
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            loadAllMovies(page: currentMoviePage)
        }
    }
    
    
    var currentShowGenre: NetworkManager.ShowGenres = .all {
        didSet {
            allShows = []
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            loadAllShows(page: currentShowPage)
        }
    }
    
    
    var currentMovieFilter: MovieManager.Filters = .trending {
        didSet {
            allMovies = []
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            loadAllMovies(page: currentMoviePage)
        }
    }
    
    
    var currentShowFilter: ShowManager.Filters = .trending {
        didSet {
            allShows = []
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            loadAllShows(page: currentShowPage)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.reloadSections(IndexSet(2 ..< 2))
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    
    func setup() {
        setupNavigationBar()
        setupCollectionView()
        configureFor(type: currentType)
    }
    
    
    func setupNavigationBar() {
        title = "Movies".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.setRightBarButtonItems([
            UIBarButtonItem(image: UIImage(systemName: "tv"), style: .plain, target: self, action: #selector(toggleMedia(sender:))),
            UIBarButtonItem(image: UIImage(systemName: "link"), style: .plain, target: self, action: #selector(downloadMagnet(sender:)))
        ], animated: true)
        
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search".localized
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    
    func setupCollectionView() {
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MainNewCollectionViewInCell.self, forCellWithReuseIdentifier: "MainNewCollectionViewInCell")
        collectionView.register(MainGenresCollectionViewInCell.self, forCellWithReuseIdentifier: "MainGenresCollectionViewInCell")
        collectionView.register(MediaCell.self, forCellWithReuseIdentifier: "MediaCell")
        collectionView.register(MainHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MainHeaderView")
        collectionView.register(MainHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MainHeaderViewWithSortButton")
    }
    
    
    func configureFor(type: Int) {
        if type == 0 {
            loadNewMovies()
            loadAllMovies(page: currentMoviePage)
            title = "Movies".localized
            tabBarController?.tabBar.items![0].image = UIImage(systemName: "film")
        } else {
            loadNewShows()
            loadAllShows(page: currentShowPage)
            title = "Shows".localized
            tabBarController?.tabBar.items![0].image = UIImage(systemName: "tv")
        }
    }
    
    
    func loadAllMovies(page: Int) {
        guard !isMovieLoading else {
            return
        }
        
        
        isMovieLoading = true
        movieHasNextPage = false
        PopcornKit.loadMovies(page, filterBy: currentMovieFilter, genre: currentMovieGenre, searchTerm: nil, orderBy: .descending) { (movies, error) in
            if let error = error {
                print("[MainMediaCollectionViewController.loadAllMovies]: \(error.localizedDescription)")
            } else {
                self.isMovieLoading = false
                
                guard let movies = movies else {
                    DispatchQueue.main.async {
                        self.collectionView.reloadSections(IndexSet(0 ..< 2))
                    }
                    return
                }
                
                
                if self.allMovies.count > 0 {
                    self.allMovies += movies
                } else {
                    self.allMovies = movies
                }
                self.allMovies.unique()
                
                
                if movies.isEmpty {
                    self.collectionView?.contentInset.bottom = self.tabBarController?.tabBar.frame.height ?? 0
                } else {
                    self.movieHasNextPage = true
                }
                
                
                DispatchQueue.main.async {
                    self.collectionView.reloadSections(IndexSet(0 ..< 2))
                }
                
                
                /*self.all = movies!
                
                DispatchQueue.main.async {
                    self.collectionView.reloadSections(IndexSet(1 ..< 2))
                }*/
            }
        }
    }
    
    
    func loadAllShows(page: Int) {
        guard !isShowLoading else {
            return
        }
        
        
        isShowLoading = true
        showHasNextPage = false
        PopcornKit.loadShows(page, filterBy: currentShowFilter, genre: currentShowGenre, searchTerm: nil, orderBy: .descending) { (shows, error) in
            if let error = error {
                print("[MainMediaCollectionViewCßontroller.loadAllShows]: \(error.localizedDescription)")
            } else {
                self.isShowLoading = false
                
                guard let shows = shows else {
                    DispatchQueue.main.async {
                        self.collectionView.reloadSections(IndexSet(0 ..< 2))
                    }
                    return
                }
                
                
                if self.allShows.count > 0 {
                    self.allShows += shows
                } else {
                    self.allShows = shows
                }
                self.allShows.unique()
                
                
                if shows.isEmpty {
                    self.collectionView?.contentInset.bottom = self.tabBarController?.tabBar.frame.height ?? 0
                } else {
                    self.showHasNextPage = true
                }
                
                
                DispatchQueue.main.async {
                    self.collectionView.reloadSections(IndexSet(0 ..< 2))
                }
            }
        }
    }
    
    
    func loadNewMovies() {
        PopcornKit.loadMovies(1, filterBy: .date, genre: .all, searchTerm: nil, orderBy: .descending) { (movies, error) in
            if let error = error {
                print("[MainMediaCollectionViewController.loadNewMovies]: \(error.localizedDescription)")
            } else {
                self.new = Array(movies!.prefix(5))
                
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
                }
            }
        }
    }
    
    
    func loadNewShows() {
        PopcornKit.loadShows(1, filterBy: .date, genre: .all, searchTerm: nil, orderBy: .descending) { (shows, error) in
            if let error = error {
                print("[MainMediaCollectionViewController.loadNewShows]: \(error.localizedDescription)")
            } else {
                self.new = Array(shows!.prefix(5))
                
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
                }
            }
        }
    }
    
    
    @objc func toggleMedia(sender: UIBarButtonItem) {
        currentType = currentType == 0 ? 1 : 0
        configureFor(type: currentType)
        sender.image = currentType == 0 ? UIImage(systemName: "tv") : UIImage(systemName: "film")
    }
    
    
    @objc func downloadMagnet(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Magnet", message: "Enter the magnet link below.", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Custom Title"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Magnet Link"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Download", style: .default, handler: { (action) in
            let title = alertController.textFields![0].text!
            let magnetLink = alertController.textFields![1].text!.removingPercentEncoding!
            let userTorrent = Torrent(health: .excellent, url: magnetLink, quality: "1080p", seeds: 100, peers: 100, size: nil)
            
            let magnetTorrent = Movie(title: title, id: "34", tmdbId: nil, slug: "magnet-link", summary: "", torrents: [userTorrent], subtitles: [:], largeBackgroundImage: nil, largeCoverImage: nil)
            
            AlertHelper.chooseQuality(media: magnetTorrent, barButton: sender) { (torrent) in
                PTTorrentDownloadManager.shared().startDownloading(fromFileOrMagnetLink: torrent.url, mediaMetadata: magnetTorrent.mediaItemDictionary)
                    
                let alertController = UIAlertController(title: "Download Started".localized, message: nil, preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                    
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        }))
        
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if currentType == 0 {
            guard let collectionView = collectionView, scrollView == collectionView, moviePaginated else {
                return
            }
            
            let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
            let height = scrollView.contentSize.height
            let reloadDistance: CGFloat = 50
            
            if y > height + reloadDistance && !isMovieLoading && movieHasNextPage {
                currentMoviePage += 1
                loadAllMovies(page: currentMoviePage)
            }
        } else {
            guard let collectionView = collectionView, scrollView == collectionView, moviePaginated else {
                return
            }
            
            let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
            let height = scrollView.contentSize.height
            let reloadDistance: CGFloat = 50
            
            if y > height + reloadDistance && !isShowLoading && showHasNextPage {
                currentShowPage += 1
                loadAllShows(page: currentShowPage)
            }
        }
    }
}


extension MainMediaCollectionViewController : UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let loadingController = LoadingViewController()
            if isSearching {
                loadingController.media = searched[indexPath.item]
            } else {
                loadingController.media = currentType == 0 ? allMovies[indexPath.item] : allShows[indexPath.item]
            }
            loadingController.modalPresentationStyle = .fullScreen
            
            present(loadingController, animated: true, completion: nil)
        }
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return isSearching ? searched.count : currentType == 0 ? allMovies.count : allShows.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let mainNewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainNewCollectionViewInCell", for: indexPath) as! MainNewCollectionViewInCell
            mainNewCell.configureWith(new: new)
            return mainNewCell
        } else if indexPath.section == 1 {
            let mainGenresCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainGenresCollectionViewInCell", for: indexPath) as! MainGenresCollectionViewInCell
            mainGenresCell.configureWith(movieGenres: NetworkManager.MovieGenres.array)
            mainGenresCell.configureWith(showGenres: NetworkManager.ShowGenres.array)
            mainGenresCell.mainViewController = self
            mainGenresCell.type = currentType
            return mainGenresCell
        } else {
            let mainAllCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCell
            if isSearching {
                mainAllCell.configureCellWith(searched[indexPath.item])
            } else {
                if currentType == 0 {
                    mainAllCell.configureCellWith(allMovies[indexPath.item])
                } else {
                    mainAllCell.configureCellWith(allShows[indexPath.item])
                }
            }
            return mainAllCell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return section == 2 ? 20 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == 2 ? 20 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return section == 2 ? UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20) : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.frame.width, height: (collectionView.frame.width * 0.5) + 56)
        } else if indexPath.section == 1 {
            return CGSize(width: collectionView.frame.width, height: 88)
        } else {
            switch UIDevice.current.userInterfaceIdiom {
                case .phone:
                    let useThreeColumns = UserDefaults.standard.bool(forKey: "useThreeColumns")
                
                    let padding: CGFloat = useThreeColumns ? 80 : 60
                    let width = collectionView.frame.width
                    let cellWidth = width - padding
                    let cellsForOrientation: CGFloat = useThreeColumns ? 3 : 2
            
                    let displayMediaTitles = UserDefaults.standard.bool(forKey: "displayMediaTitles")
                    let addedHeight: CGFloat = displayMediaTitles ? 31.34 : 0
                
                    return CGSize(width: cellWidth/cellsForOrientation, height: ((cellWidth/cellsForOrientation)*1.65) + addedHeight)
                case .pad:
                    let padding: CGFloat = 60
                    let width = collectionView.frame.width
                    let cellWidth = width - padding
                    let cellsForOrientation: CGFloat = 8
            
                    let displayMediaTitles = UserDefaults.standard.bool(forKey: "displayMediaTitles")
                    let addedHeight: CGFloat = displayMediaTitles ? 31.34 : 0
                
                    return CGSize(width: cellWidth/cellsForOrientation, height: ((cellWidth/cellsForOrientation)*1.65) + addedHeight)
                
                default:
                    return .zero
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 || indexPath.section == 1 {
            let mainHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MainHeaderView", for: indexPath) as! MainHeaderView
            mainHeaderView.titleLabel.text = indexPath.section == 0 ? "New".localized : "Genres".localized
            return mainHeaderView
        } else {
            let mainHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MainHeaderViewWithSortButton", for: indexPath) as! MainHeaderView
            mainHeaderView.addSortButton()
            mainHeaderView.mainViewController = self
            mainHeaderView.titleLabel.text = isSearching ? "Searched".localized : currentType == 0 ? currentMovieGenre.string.localized : currentShowGenre.string.localized
            return mainHeaderView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}


// MARK: UISearchControllerDelegate (Extension)
extension MainMediaCollectionViewController : UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        DispatchQueue.main.async {
            self.collectionView.reloadSections(IndexSet(2 ..< 2))
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //isSearching = false
        isSearching = true
        let text = searchBar.text
        
        if currentType == 0 {
            PopcornKit.loadMovies(searchTerm: text) { searchedMovies, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.searched = searchedMovies!
                    DispatchQueue.main.async {
                        self.collectionView.reloadSections(IndexSet(2 ..< 2))
                    }
                }
            }
        } else {
            PopcornKit.loadShows(searchTerm: text) { searchedShows, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.searched = searchedShows!
                    DispatchQueue.main.async {
                        self.collectionView.reloadSections(IndexSet(2 ..< 2))
                    }
                }
            }
        }
    }
}
