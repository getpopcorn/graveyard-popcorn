//
//  MovieDetailsCollectionViewController.swift
//  Popcorn-iOS
//
//  Created by Antique on 14/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import GSKStretchyHeaderView
import PopcornKit
import UIKit

class MovieDetailsCollectionViewController : UICollectionViewController {
    var media: Media!
    var stretchyHeader: MediaDetailsStretchyHeaderView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stretchyHeader.setNeedsLayout()
    }
    
    
    func setup() {
        setupNavigationBar()
        addStretchyHeaderView()
        setupCollectionView()
    }
    
    
    func setupNavigationBar() {
        navigationController?.setNavigationControllerTransparent(transparent: true, animated: true)
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeDetails)), animated: true)
        navigationItem.setRightBarButtonItems([
            UIBarButtonItem(image: media.isAddedToWatchlist ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"), style: .done, target: self, action: #selector(toggleWatchlist(sender:)))
        ], animated: true)
    }
    
    
    func addStretchyHeaderView() {
        let headerSize = CGSize(width: view.frame.size.width, height: view.bounds.height)
        self.stretchyHeader = MediaDetailsStretchyHeaderView(frame: CGRect(x: 0, y: 0, width: headerSize.width, height: headerSize.height))
        self.stretchyHeader.configureCellWith(media)
        collectionView.addSubview(stretchyHeader)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsets(top: view.bounds.width*1.65, left: 0, bottom: (UIApplication.shared.windows[0].windowScene?.statusBarManager?.statusBarFrame.height)!, right: 0)
    }
    
    
    func setupCollectionView() {
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MediaDetailsTrailerCollectionViewInCell.self, forCellWithReuseIdentifier: "MediaDetailsTrailerCollectionViewInCell")
        collectionView.register(MediaDetailsSeasonCollectionViewInCell.self, forCellWithReuseIdentifier: "MediaDetailsSeasonCollectionViewInCell")
        collectionView.register(MediaRatingCell.self, forCellWithReuseIdentifier: "MediaRatingCell")
        collectionView.register(MediaDetailsCastCollectionViewInCell.self, forCellWithReuseIdentifier: "MediaDetailsCastCollectionViewInCell")
        collectionView.register(MediaDetailsCrewCollectionViewInCell.self, forCellWithReuseIdentifier: "MediaDetailsCrewCollectionViewInCell")
        collectionView.register(MediaRelatedCollectionViewCell.self, forCellWithReuseIdentifier: "MediaRelatedCollectionViewCell")
        collectionView.register(MediaDetailsHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MediaDetailsHeaderView")
    }
    
    
    @objc func closeDetails() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func toggleWatchlist(sender: UIBarButtonItem) {
        let firestore = Firestore.firestore()
        let isSignedIn = UserDefaults.standard.bool(forKey: "isSignedIn")
        let user = isSignedIn ? Auth.auth().currentUser : nil
        var isAddedToWatchlist = false
        firestore.collection("watchlist").document(user!.uid).getDocument { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let media = self.media!
                let movies = snapshot?.data()?["watchlist_movies"] as! [String]
                isAddedToWatchlist = movies.contains(media.id)
                
                
                if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
                    WatchlistManager<Movie>.movie.toggle(media as! Movie)
                    if isSignedIn {
                        firestore.collection("watchlist").document(user!.uid).setData([
                            "watchlist_movies" : isAddedToWatchlist ? FieldValue.arrayRemove([media.id]) : FieldValue.arrayUnion([media.id])
                        ], merge: true)
                    }
                } else {
                    WatchlistManager<Show>.show.toggle(media as! Show)
                    if isSignedIn {
                        firestore.collection("watchlist").document(user!.uid).setData([
                            "watchlist_shows" : isAddedToWatchlist ? FieldValue.arrayRemove([media.id]) : FieldValue.arrayUnion([media.id])
                        ], merge: true)
                    }
                }
                
                
                isAddedToWatchlist = movies.contains(media.id)
                sender.image = isAddedToWatchlist ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
            }
        }
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let normalized = scrollView.contentOffset.y
        let headerHeight = view.bounds.width*1.65
        
        
        if let header = stretchyHeader {
            header.alpha = abs(normalized/headerHeight)
        }
    }
}


extension MovieDetailsCollectionViewController : UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            return movie_collectionView(collectionView, cellForItemAt: indexPath)
        } else {
            return show_collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    
    func movie_collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let detailRatingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaRatingCell", for: indexPath) as! MediaRatingCell
            detailRatingCell.setProgress(progress: Float((media as! Movie).rating))
            return detailRatingCell
        } else if indexPath.section == 1 {
            let detailsTrailerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDetailsTrailerCollectionViewInCell", for: indexPath) as! MediaDetailsTrailerCollectionViewInCell
            detailsTrailerCell.configureWith(media: media)
            return detailsTrailerCell
        } else if indexPath.section == 2 {
            let detailsCastCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDetailsCastCollectionViewInCell", for: indexPath) as! MediaDetailsCastCollectionViewInCell
            detailsCastCell.configureWith(media: media)
            return detailsCastCell
        } else if indexPath.section == 3 {
            let detailsCrewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDetailsCrewCollectionViewInCell", for: indexPath) as! MediaDetailsCrewCollectionViewInCell
            detailsCrewCell.configureWith(media: media)
            return detailsCrewCell
        } else {
            let detailsRelatedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaRelatedCollectionViewCell", for: indexPath) as! MediaRelatedCollectionViewCell
            detailsRelatedCell.configureCellWith(media)
            return detailsRelatedCell
        }
    }
    
    
    func show_collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let detailRatingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaRatingCell", for: indexPath) as! MediaRatingCell
            detailRatingCell.setProgress(progress: Float((media as! Show).rating))
            return detailRatingCell
        } else if indexPath.section == 1 {
            let detailsSeasonCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDetailsSeasonCollectionViewInCell", for: indexPath) as! MediaDetailsSeasonCollectionViewInCell
            detailsSeasonCell.configureWith(media: media)
            return detailsSeasonCell
        } else if indexPath.section == 2 {
            let detailsCastCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDetailsCastCollectionViewInCell", for: indexPath) as! MediaDetailsCastCollectionViewInCell
            detailsCastCell.configureWith(media: media)
            return detailsCastCell
        } else if indexPath.section == 3 {
            let detailsCrewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDetailsCrewCollectionViewInCell", for: indexPath) as! MediaDetailsCrewCollectionViewInCell
            detailsCrewCell.configureWith(media: media)
            return detailsCrewCell
        } else {
            let detailsRelatedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaRelatedCollectionViewCell", for: indexPath) as! MediaRelatedCollectionViewCell
            detailsRelatedCell.configureCellWith(media)
            return detailsRelatedCell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            switch indexPath.section {
                case 1, 2, 3:
                    return CGSize(width: collectionView.frame.width, height: collectionView.frame.width*0.5)
                case 0:
                    return CGSize(width: collectionView.frame.width, height: 88)
                default:
                    return CGSize(width: collectionView.frame.width, height: 296)
            }
        } else {
            switch indexPath.section {
                case 1, 2, 3:
                    return CGSize(width: collectionView.frame.width, height: collectionView.frame.width*0.5)
                case 0:
                    return CGSize(width: collectionView.frame.width, height: 88)
                default:
                    return CGSize(width: collectionView.frame.width, height: 296)
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let mainHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MediaDetailsHeaderView", for: indexPath) as! MediaDetailsHeaderView
        switch indexPath.section {
            case 0:
                mainHeaderView.titleLabel.text = "Rating".localized
            case 1:
                mainHeaderView.titleLabel.text = (media.mediaItemDictionary["mediaType"] as! Int) == 256 ? "Trailer".localized : "Seasons".localized
            case 2:
                mainHeaderView.titleLabel.text = "Cast".localized
            case 3:
                mainHeaderView.titleLabel.text = "Crew".localized
            case 4:
                mainHeaderView.titleLabel.text = "Related".localized
            default:
                mainHeaderView.titleLabel.text = ""
            }
        return mainHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}
