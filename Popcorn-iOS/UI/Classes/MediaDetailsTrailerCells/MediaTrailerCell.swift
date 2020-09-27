//
//  MediaTrailerCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 15/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import UIKit

class MediaTrailerCell : UICollectionViewCell {
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
        addContainerView()
        addImageView()
        addPlayImageView()
    }
    
    
    func addContainerView() {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    
    func addImageView() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .secondarySystemBackground
        containerView.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }
    
    
    func addPlayImageView() {
        let playImageView = UIImageView(image: UIImage(systemName: "play.fill"))
        playImageView.translatesAutoresizingMaskIntoConstraints = false
        playImageView.contentMode = .scaleAspectFit
        playImageView.layer.shadowColor = UIColor.black.cgColor
        playImageView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        playImageView.layer.shadowOpacity = 0.08
        playImageView.layer.shadowRadius = 8
        playImageView.tintColor = .white
        containerView.addSubview(playImageView)
        
        playImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        playImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        playImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        playImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    
    func configureFor(media: Media) {
        guard let movie = media as? Movie else {
            print("[e]: Initializing cell with invalid item");
            return
        }
        
        
        if let image = movie.mediumBackgroundImage, let url = URL(string: image) {
            imageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "missing_background"), imageTransition: .crossDissolve(0.33))
        } else {
            imageView.image = UIImage(named: "missing_background")
        }
    }
}
