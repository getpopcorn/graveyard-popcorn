//
//  MediaDetailsSeasonEpisodesCollectionViewController.swift
//  Popcorn-iOS
//
//  Created by Antique on 15/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import UIKit

class MediaDetailsSeasonEpisodesCollectionViewController : UICollectionViewController {
    var episodes = [Episode]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    func setup() {
        setupNavigationBar()
        setupCollectionView()
    }
    
    
    func setupNavigationBar() {
        title = "Season".localized
        title?.append(" \(episodes[0].season)")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeDetails)), animated: true)
    }
    
    
    func setupCollectionView() {
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MediaDetailsSeasonEpisodeCell.self, forCellWithReuseIdentifier: "MediaDetailsSeasonEpisodeCell")
    }
    
    
    @objc func closeDetails() {
        dismiss(animated: true, completion: nil)
    }
}


extension MediaDetailsSeasonEpisodesCollectionViewController : UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let seasonEpisodeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDetailsSeasonEpisodeCell", for: indexPath) as! MediaDetailsSeasonEpisodeCell
        seasonEpisodeCell.configureCellWith(episodes[indexPath.item])
        return seasonEpisodeCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width-40, height: 74)
    }
}
