//
//  MediaCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 14/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AlamofireImage
import Foundation
import PopcornKit
import UIKit

class MediaCell : UICollectionViewCell {
    var shadowView = UIView()
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    var mediaLabel: TopAlignLabel = {
        let label = TopAlignLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = .label
        return label
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
        imageView.round(corners: .allCorners, radius: 10, usesBorder: false, borderColor: .clear, borderWidth: 0)
        shadowView.round(radius: 10, shadowColor: .black, shadowOffset: CGSize(width: 0, height: 0.5), shadowOpacity: 0.08, shadowRadius: 10)
    }
    
    
    func setup() {
        backgroundColor = .clear
        let displayMediaTitles = UserDefaults.standard.bool(forKey: "displayMediaTitles")
        
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(shadowView)
        
        shadowView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        shadowView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        shadowView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        
        shadowView.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: shadowView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor).isActive = true
        
        
        addSubview(mediaLabel)
        
        mediaLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mediaLabel.heightAnchor.constraint(equalToConstant: displayMediaTitles ?  31.34 : 0).isActive = true
        mediaLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        mediaLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: mediaLabel.topAnchor, constant: displayMediaTitles ? -8 : 0).isActive = true
    }
    
    
    func configureCellWith<T>(_ item: T) {
        guard let media = item as? Media else {
            print("[e]: Initializing cell with invalid item")
            return
        }
        
        mediaLabel.text = media.title
        
        
        if let image = media.smallCoverImage, let url = URL(string: image) {
            imageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "movie_placeholder"), imageTransition: .crossDissolve(0.33))
        } else {
            imageView.image = UIImage(named: "movie_placeholder")
        }
    }
}
