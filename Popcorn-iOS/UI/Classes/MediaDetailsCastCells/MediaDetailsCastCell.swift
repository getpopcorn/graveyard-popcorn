//
//  MediaDetailsCastCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 15/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import PopcornTorrent
import UIKit

class MediaDetailsCastCell : UICollectionViewCell {
    var shadowView = UIView()
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    var personaLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .secondaryLabel
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
        imageView.round(corners: .allCorners, radius: imageView.bounds.height/2, usesBorder: false, borderColor: .clear, borderWidth: 0)
        shadowView.round(radius: shadowView.bounds.height/2, shadowColor: .black, shadowOffset: CGSize(width: 0, height: 0.5), shadowOpacity: 0.08, shadowRadius: 6)
    }
    
    
    func setup() {
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(shadowView)
        
        shadowView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        shadowView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        shadowView.heightAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        shadowView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: shadowView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor).isActive = true
        
        
        addSubview(nameLabel)
        
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        
        addSubview(personaLabel)
        
        personaLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        personaLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        personaLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    
    func configureCellWith<T>(_ item: T) {
        guard let media = item as? Actor else {
            print("[e]: Initializing cell with invalid item");
            return
        }
        
        
        nameLabel.text = media.name
        personaLabel.text = media.characterName
        
        
        if let image = media.smallImage, let url = URL(string: image) {
            self.imageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "missing_background"), imageTransition: .crossDissolve(0.33))
        } else {
            self.imageView.image = UIImage(named: "missing_background")
        }
    }
}
