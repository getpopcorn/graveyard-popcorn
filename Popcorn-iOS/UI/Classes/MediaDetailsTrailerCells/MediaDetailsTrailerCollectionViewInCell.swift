//
//  MediaDetailsTrailerCollectionViewInCell.swift
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

class MediaDetailsTrailerCollectionViewInCell : UICollectionViewCell {
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
        collectionView.register(MediaTrailerCell.self, forCellWithReuseIdentifier: "MediaTrailerCell")
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


extension MediaDetailsTrailerCollectionViewInCell : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        XCDYouTubeClient.default().getVideoWithIdentifier((media as! Movie).trailerCode) { (video, error) in
            guard let urls = video?.streamURLs, let qualities = Array(urls.keys) as? [UInt] else {
                return
            }
                
            let preferredQualities = [XCDYouTubeVideoQuality.HD720.rawValue, XCDYouTubeVideoQuality.medium360.rawValue, XCDYouTubeVideoQuality.small240.rawValue]
            var videoURL: URL?
                
            for quality in preferredQualities {
                if let index = qualities.firstIndex(of: quality) {
                    videoURL = Array(urls.values)[index]
                    break
                }
            }
                
            guard let url = videoURL else {
                let alertController = UIAlertController(title: "Error", message: "Error fetching valid trailer URL from YouTube.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.currentViewController()?.present(alertController, animated: true)
                return
            }
                
            let player = AVPlayer(url: url)
            let playerController = AVPlayerViewController()
            playerController.player = player
            player.play()
                
            self.currentViewController()?.present(playerController, animated: true, completion: nil)
        }
    }
}


extension MediaDetailsTrailerCollectionViewInCell : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let trailerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaTrailerCell", for: indexPath) as! MediaTrailerCell
        trailerCell.configureFor(media: media)
        return trailerCell
    }
}


extension MediaDetailsTrailerCollectionViewInCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 32, bottom: 20, right: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = collectionView.frame.height
        
        return CGSize(width: (height-40)*1.65, height: height-40)
    }
}
