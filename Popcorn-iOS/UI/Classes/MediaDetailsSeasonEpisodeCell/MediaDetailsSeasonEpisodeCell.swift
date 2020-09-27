//
//  MediaDetailsSeasonEpisodeCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 15/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import PopcornTorrent
import UIKit

class MediaDetailsSeasonEpisodeCell : UICollectionViewCell {
    var media: Media!
    
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    var labelView = CenteredLabelView()
    
    
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
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.66).isActive = true
        
        
        let streamButton = UIButton(type: .system)
        streamButton.translatesAutoresizingMaskIntoConstraints = false
        streamButton.addTarget(self, action: #selector(streamTorrent(sender:)), for: .touchUpInside)
        streamButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        streamButton.imageView?.contentMode = .scaleAspectFit
        addSubview(streamButton)
        
        streamButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        streamButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        streamButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        streamButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        
        let downloadButton = UIButton(type: .system)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.addTarget(self, action: #selector(downloadTorrent(sender:)), for: .touchUpInside)
        downloadButton.setImage(UIImage(systemName: "icloud.and.arrow.down.fill"), for: .normal)
        downloadButton.imageView?.contentMode = .scaleAspectFit
        addSubview(downloadButton)
        
        downloadButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        downloadButton.trailingAnchor.constraint(equalTo: streamButton.leadingAnchor, constant: -12).isActive = true
        downloadButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        downloadButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        
        addSubview(labelView)
        
        labelView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        labelView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12).isActive = true
        labelView.trailingAnchor.constraint(equalTo: downloadButton.leadingAnchor, constant: -16).isActive = true
    }
    
    
    @objc func streamTorrent(sender: UIButton) {
        AlertHelper.chooseQuality(media: self.media, button: sender) { (torrent) in
            let streamNavController = UINavigationController(rootViewController: StreamProgressViewController())
            streamNavController.modalPresentationStyle = .fullScreen
                    
            (streamNavController.viewControllers[0] as! StreamProgressViewController).media = self.media
            (streamNavController.viewControllers[0] as! StreamProgressViewController).shouldUseSubtitles = false
            (streamNavController.viewControllers[0] as! StreamProgressViewController).torrent = torrent
            self.currentViewController()?.present(streamNavController, animated: true, completion: nil)
        }
    }
    
    
    @objc func downloadTorrent(sender: UIButton) {
        AlertHelper.chooseQuality(media: media, button: sender) { (torrent) in
            PTTorrentDownloadManager.shared().startDownloading(fromFileOrMagnetLink: torrent.url, mediaMetadata: self.media.mediaItemDictionary)
                    
            let alertController = UIAlertController(title: "Download Started".localized, message: nil, preferredStyle: .alert)
            self.currentViewController()?.present(alertController, animated: true, completion: nil)
                    
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    func configureCellWith<T>(_ item: T) {
        guard let media = item as? Episode else {
            print("[e]: Initializing cell with invalid item");
            return
        }
        self.media = media
        
        
        labelView.titleLabel.text = "\(media.episode). \(media.title)"
        labelView.subtitleLabel.text = media.summary
        
        
        if let image = media.smallBackgroundImage, let url = URL(string: image) {
            self.imageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "missing_background"), imageTransition: .crossDissolve(0.33))
        } else {
            self.imageView.image = UIImage(named: "missing_background")
        }
    }
}

