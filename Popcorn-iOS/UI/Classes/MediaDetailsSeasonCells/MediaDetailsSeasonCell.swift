//
//  MediaDetailsSeasonCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 15/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AlamofireImage
import Foundation
import PopcornKit
import UIKit

class MediaDetailsSeasonCell : UICollectionViewCell {
    var shadowView = UIView()
    
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    var seasonTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.black.withAlphaComponent(0.66)
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textAlignment = .center
        textView.textColor = .white
        textView.textContainerInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        return textView
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
        seasonTextView.round(corners: .allCorners, radius: 6, usesBorder: false, borderColor: .clear, borderWidth: 0)
    }
    
    
    func setup() {
        backgroundColor = .clear
        
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(shadowView)
        
        shadowView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        shadowView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        shadowView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        
        shadowView.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: shadowView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor).isActive = true
        
        
        shadowView.addSubview(seasonTextView)
        
        seasonTextView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor, constant: 8).isActive = true
        seasonTextView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: -8).isActive = true
    }
    
    
    func configureCellWith<T>(_ item: T) {
        guard let media = item as? Episode else {
            print("[e]: Initializing cell with invalid item")
            return
        }
        
        
        seasonTextView.text = "Season".localized
        seasonTextView.text.append(" \(media.season)")
        
        if let image = media.smallBackgroundImage, let url = URL(string: image) {
            imageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "movie_placeholder"), imageTransition: .crossDissolve(0.33))
        } else {
            imageView.image = UIImage(named: "movie_placeholder")
        }
    }
}
