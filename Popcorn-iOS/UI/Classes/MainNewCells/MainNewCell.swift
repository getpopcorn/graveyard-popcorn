//
//  MainGenreCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 14/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AlamofireImage
import Foundation
import PopcornKit
import UIKit

class MainNewCell : UICollectionViewCell {
    var containerView: UIView!
    var imageView: UIImageView!
    
    
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
        containerView.round(radius: 10, shadowColor: .black, shadowOffset: CGSize(width: 0, height: 0.5), shadowOpacity: 0.08, shadowRadius: 10)
        imageView.round(corners: .allCorners, radius: 10, usesBorder: false, borderColor: .clear, borderWidth: 0)
    }
    
    
    func setup() {
        backgroundColor = .systemBackground
        
        addContainerView()
        addImageView()
    }
    
    
    func addContainerView() {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }
    
    
    func addImageView() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }
    
    
    func configureFor(media: Media) {
        (media.mediaItemDictionary["mediaType"] as! Int) == 256 ? configureFor(movie: (media as! Movie)) : configureFor(show: (media as! Show))
    }
    
    
    func configureFor(movie: Movie) {
        if let image = movie.smallBackgroundImage, let url = URL(string: image) {
            imageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "missing_background"), imageTransition: .crossDissolve(0.33))
        } else {
            imageView.image = UIImage(named: "missing_background")
        }
    }
    
    
    func configureFor(show: Show) {
        if let image = show.smallBackgroundImage, let url = URL(string: image) {
            imageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "missing_background"), imageTransition: .crossDissolve(0.33))
        } else {
            imageView.image = UIImage(named: "missing_background")
        }
    }
}
