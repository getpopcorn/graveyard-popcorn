//
//  MediaQueueDownloadCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 16/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AlamofireImage
import Foundation
import PopcornKit
import PopcornTorrent
import RPCircularProgress
import UIKit

class MediaQueueDownloadCell : UICollectionViewCell {
    var torrent: PTTorrentDownload!
    
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    var labelView = CenteredLabelView()
    var progressView: RPCircularProgress = {
        let progressView = RPCircularProgress()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .tertiarySystemBackground
        progressView.progressTintColor = .systemBlue
        progressView.roundedCorners = false
        progressView.thicknessRatio = 1
        return progressView
    }()
    
    
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
        round(corners: .allCorners, radius: 10, usesBorder: false, borderColor: .clear, borderWidth: 0)
        imageView.round(corners: .allCorners, radius: 6, usesBorder: false, borderColor: .clear, borderWidth: 0)
    }
    
    
    func setup() {
        backgroundColor = .secondarySystemBackground
        
        
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.65).isActive = true
        
        
        addSubview(progressView)
        
        progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        progressView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        progressView.widthAnchor.constraint(equalToConstant: 29).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 29).isActive = true
        
        
        labelView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(labelView)
        
        labelView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        labelView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12).isActive = true
        labelView.trailingAnchor.constraint(equalTo: progressView.leadingAnchor, constant: -32).isActive = true
    }
    
    
    func configureCellWith<T>(_ item: T) {
        guard let media = item as? PTTorrentDownload else {
            print("[e]: Initializing cell with invalid item");
            return
        }
        torrent = media
        
        
        labelView.titleLabel.text = media.mediaMetadata["title"] as? String
        labelView.subtitleLabel.text = "Processing".localized
        
        
        if let image = media.mediaMetadata["backgroundArtwork"], let url = URL(string: image as! String) {
            self.imageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "missing_background"), imageTransition: .crossDissolve(0.33))
        } else {
            self.imageView.image = UIImage(named: "missing_background")
        }
    }
}
