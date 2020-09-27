//
//  MediaDetailsCrewCollectionViewInCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 15/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AVKit
import Foundation
import PopcornKit
import UIKit
import XCDYouTubeKit

class MediaDetailsCrewCollectionViewInCell : UICollectionViewCell {
    var media: Media!
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
        collectionView.register(MediaDetailsCrewCell.self, forCellWithReuseIdentifier: "MediaDetailsCrewCell")
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    
    func configureWith(media: Media) {
        self.media = media
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}


extension MediaDetailsCrewCollectionViewInCell : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}


extension MediaDetailsCrewCollectionViewInCell : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (media.mediaItemDictionary["mediaType"] as! Int) == 256 ? (media as! Movie).crew.count : (media as! Show).crew.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let trailerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDetailsCrewCell", for: indexPath) as! MediaDetailsCrewCell
        trailerCell.configureCellWith((media.mediaItemDictionary["mediaType"] as! Int) == 256 ? (media as! Movie).crew[indexPath.item] : (media as! Show).crew[indexPath.item])
        return trailerCell
    }
}


extension MediaDetailsCrewCollectionViewInCell : UICollectionViewDelegateFlowLayout {
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
        
        return CGSize(width: 80, height: height-40)
    }
}
