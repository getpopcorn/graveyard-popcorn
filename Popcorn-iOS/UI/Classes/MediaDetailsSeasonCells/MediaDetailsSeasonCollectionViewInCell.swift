//
//  MediaDetailsSeasonCollectionViewInCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 15/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AVKit
import Foundation
import PopcornKit
import UIKit

class MediaDetailsSeasonCollectionViewInCell : UICollectionViewCell {
    var media: Show!
    var episodes = [Episode]()
    var collectionView: UICollectionView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    func setup() {
        addCollectionView()
    }
    
    
    func addCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MediaDetailsSeasonCell.self, forCellWithReuseIdentifier: "MediaDetailsSeasonCell")
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    
    func change(to season: Int) -> [Episode] {
        episodes = media.episodes.filter({$0.season == season}).sorted(by: {$0.episode < $1.episode})
        return episodes
    }
    
    
    func configureWith(media: Media) {
        self.media = media as? Show
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}


extension MediaDetailsSeasonCollectionViewInCell : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let seasonEpisodesCollectionViewController = UINavigationController(rootViewController: MediaDetailsSeasonEpisodesCollectionViewController(collectionViewLayout: flowLayout))
        seasonEpisodesCollectionViewController.modalPresentationStyle = .fullScreen
        (seasonEpisodesCollectionViewController.viewControllers[0] as! MediaDetailsSeasonEpisodesCollectionViewController).episodes = change(to: 1+indexPath.item)
        currentViewController()?.present(seasonEpisodesCollectionViewController, animated: true, completion: nil)
    }
}


extension MediaDetailsSeasonCollectionViewInCell : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media.seasonNumbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let seasonCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDetailsSeasonCell", for: indexPath) as! MediaDetailsSeasonCell
        let episodes = change(to: 1+indexPath.item)
        seasonCell.configureCellWith(episodes[0])
        return seasonCell
    }
}


extension MediaDetailsSeasonCollectionViewInCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 32, bottom: 20, right: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = collectionView.frame.height
        
        return CGSize(width: (height-40)*1.65, height: height-40)
    }
}
