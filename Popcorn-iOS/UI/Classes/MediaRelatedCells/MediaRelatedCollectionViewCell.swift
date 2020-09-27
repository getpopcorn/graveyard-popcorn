//
//  MediaRelatedTableViewCell.swift
//  Popcorn-iOS
//
//  Created by Jarrod Norwell on 28/6/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import UIKit

class MediaRelatedCollectionViewCell : UICollectionViewCell {
    var collectionView: UICollectionView!
    var related = [Media]()
    var media: Media!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print(collectionView.collectionViewLayout.collectionViewContentSize.height)
    }
    
    
    func setup() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.clipsToBounds = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MediaRelatedCell.self, forCellWithReuseIdentifier: "MediaRelatedCell")
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    
    func configureCellWith<T>(_ item: T) {
        guard let completeMedia = item as? Media else {
            print("[e]: Initializing cell with invalid item");
            return
        }
        
        media = completeMedia
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}


extension MediaRelatedCollectionViewCell : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            let movie = (media as! Movie).related[indexPath.item]
            
            let loadingController = LoadingViewController()
            loadingController.media = movie
            loadingController.modalPresentationStyle = .fullScreen
            
            currentViewController()?.present(loadingController, animated: true, completion: nil)
        } else {
            let show = (media as! Show).related[indexPath.item]
            
            let loadingController = LoadingViewController()
            loadingController.media = show
            loadingController.modalPresentationStyle = .fullScreen
            
            currentViewController()?.present(loadingController, animated: true, completion: nil)
        }
    }
}

extension MediaRelatedCollectionViewCell : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            return (media as! Movie).related.count
        } else {
            return (media as! Show).related.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let relatedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaRelatedCell", for: indexPath) as! MediaRelatedCell
        
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            relatedCell.configureCellWith((media as! Movie).related[indexPath.item])
        } else {
            relatedCell.configureCellWith((media as! Show).related[indexPath.item])
        }
        
        return relatedCell
    }
    
    
    //func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //section = indexPath.section
    //}
}


extension MediaRelatedCollectionViewCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 32, bottom: 20, right: 32)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice().userInterfaceIdiom == .phone {
            return iPhone_collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        } else {
            return iPad_collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
    }
    
    
    func iPad_collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width*0.33, height: collectionView.frame.height-32)
    }
    
    func iPhone_collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width*0.66, height: collectionView.frame.height-32)
    }
}
