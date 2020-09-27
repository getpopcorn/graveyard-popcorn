//
//  MediaWatchlistCollectionViewController.swift
//  Popcorn-iOS
//
//  Created by Antique on 22/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AVFoundation
import AVKit
import Foundation
import GCDWebServer
import PopcornKit
import PopcornTorrent
import UIKit

class MediaWatchlistCollectionViewController : UICollectionViewController {
    var watchlist = [[Media]]()
    var segmentControl = UISegmentedControl()
    
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Watchlist".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.register(WatchlistCell.self, forCellWithReuseIdentifier: "WatchlistCell")
        collectionView.register(NoContentCell.self, forCellWithReuseIdentifier: "NoContentCell")
        collectionView.register(MainHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MainHeaderView")
    }
    
    // MARK: viewWillAppear(_ animated: Bool)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load()
    }
    
    
    // MARK: load()
    func load() {
        let movies = WatchlistManager<Movie>.movie.getWatchlist()
        let shows = WatchlistManager<Show>.show.getWatchlist()
        
        
        self.watchlist = [movies, shows]
        self.didRefresh(collectionView: self.collectionView)
    }
    
    
    // MARK: didRefresh(collectionView: UICollectionView)
    func didRefresh(collectionView: UICollectionView) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    
    // MARK: alert(segment: Int, media: Media)
    func alert(media: Media, cell: UICollectionViewCell) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = cell
        }
        
        var media = media
        alertController.addAction(UIAlertAction(title: "View".localized, style: .default, handler: { (alert) in
            let loadingController = LoadingViewController()
            loadingController.media = media
            loadingController.modalPresentationStyle = .fullScreen
                    
            self.present(loadingController, animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Remove".localized, style: .destructive, handler: { (alert) in
            media.isAddedToWatchlist = false
            alertController.dismiss(animated: true, completion: nil)
                    
            self.load()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (alert) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
}


extension MediaWatchlistCollectionViewController : UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if watchlist[section].count > 0 {
            return watchlist[section].count
        } else {
            return 1
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if watchlist[indexPath.section].count > 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WatchlistCell", for: indexPath) as! WatchlistCell
            cell.configureCellWith(watchlist[indexPath.section][indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoContentCell", for: indexPath) as! NoContentCell
            cell.noContentLabel.text = indexPath.section == 0 ? "No Movies Saved".localized : "No Shows Saved".localized
            return cell
        }
    }
    
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if watchlist[indexPath.section].count > 0 {
            alert(media: watchlist[indexPath.section][indexPath.item], cell: collectionView.cellForItem(at: indexPath)!)
        }
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                let padding: CGFloat = 40
                let width = collectionView.frame.width
                let cellWidth = width - padding
            
                return CGSize(width: cellWidth, height: watchlist[indexPath.section].count > 0 ? 72 : 48)
            case .pad:
                let padding: CGFloat = 27
                let width = collectionView.frame.width
                let cellWidth = (width/3) - padding
            
                return CGSize(width: cellWidth, height: 72)
            default:
                return .zero
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let mainHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MainHeaderView", for: indexPath) as! MainHeaderView
        switch indexPath.section {
            case 0:
                mainHeaderView.titleLabel.text = "Movies".localized
            case 1:
                mainHeaderView.titleLabel.text = "Shows".localized
            default:
                mainHeaderView.titleLabel.text = ""
            }
        return mainHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}
