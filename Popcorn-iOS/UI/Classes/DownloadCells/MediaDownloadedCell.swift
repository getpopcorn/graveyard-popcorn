//
//  MediaDownloadedCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 16/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import PopcornTorrent
import UIKit

class MediaDownloadedCell : UICollectionViewCell {
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
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.65).isActive = true
        
        
        addSubview(labelView)
        
        labelView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        labelView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12).isActive = true
        labelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = true
    }
    
    
    func configureCellWith<T>(_ item: T) {
        guard let media = item as? PTTorrentDownload else {
            print("[e]: MediaDownloadedCell.configureCellWith(_:)");
            return
        }
        
        
        labelView.titleLabel.text = media.mediaMetadata["title"] as? String
        
        
        let isMP4 = media.fileName!.contains(".mp4")
        let color = isMP4 ? UIColor.systemBlue : UIColor.systemRed
        
        
        let fileSizeString = NSMutableAttributedString(string: "\(media.fileSize.stringValue)", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel
        ])
        
        
        let fileFormatString = NSMutableAttributedString(string: "\(media.fileName!.contains(".mp4") ? "MP4".localized : "MKV".localized)", attributes: [
            NSAttributedString.Key.foregroundColor : color
        ])
        
        
        let spacingString = NSMutableAttributedString(string: " • ", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel
        ])
        
        
        let composition = NSMutableAttributedString()
        composition.append(fileSizeString)
        composition.append(spacingString)
        composition.append(fileFormatString)
        labelView.subtitleLabel.attributedText = composition
        
        
        if !FileManager.default.fileExists(atPath: media.savePath!.appending("/artwork.png")) {
            if let image = media.mediaMetadata["backgroundArtwork"], let url = URL(string: image as! String) {
                self.imageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "missing_background"), imageTransition: .crossDissolve(0.33))
            } else {
                self.imageView.image = UIImage(named: "missing_background")
            }
        } else {
            self.imageView.image = UIImage(contentsOfFile: media.savePath!.appending("/artwork.png"))
        }
    }
}
