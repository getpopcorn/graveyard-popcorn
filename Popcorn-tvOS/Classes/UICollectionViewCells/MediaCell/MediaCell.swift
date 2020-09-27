//
//  MediaCell.swift
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 15/6/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AlamofireImage
import Foundation
import PopcornKit_tvOS
import UIKit

class MediaCell : UICollectionViewCell {
    var scale: CGFloat = 0.0
    
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .black
        return imageView
    }()
    
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0.0
        label.font = UIFont.systemFont(ofSize: 17)
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
        imageView.round(corners: .allCorners, radius: 8, usesBorder: false, borderColor: .clear, borderWidth: 0)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        struct wrapper {
            static let s_atvMotionEffect = UIMotionEffectGroup()
        }

        coordinator.addCoordinatedAnimations({
            if self.isFocused {
                self.addMotionEffect(wrapper.s_atvMotionEffect)
                self.layer.shadowOpacity = 0.33;
                self.layer.shadowRadius = 16.0;
                self.layer.shadowOffset = CGSize(width: 0, height: 5);
                self.scale = 1.05
                self.imageView.alpha = 1.00
                self.titleLabel.alpha = 1.0
                let transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
                self.layer.setAffineTransform(transform)
            } else {
                self.removeMotionEffect(wrapper.s_atvMotionEffect)
                self.layer.shadowOpacity = 0.25;
                self.layer.shadowRadius = 8.0;
                self.layer.shadowOffset = CGSize(width: 0, height: 0);
                self.scale = 1.0
                self.imageView.alpha = 0.5
                self.titleLabel.alpha = 0.0
                let transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
                self.layer.setAffineTransform(transform)
            }
        }, completion: nil)
    }
    
    
    func setup() {
        imageView.alpha = 0.5
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        
        addSubview(titleLabel)
        
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
    }
    
    
    @objc func startSelectAnimation() {
        scale = 1.05
        UIView.animate(withDuration: 0.33) {
            self.imageView.alpha = 1.0
            self.titleLabel.alpha = 1.0
        }
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        layer.setAffineTransform(transform)
        perform(#selector(middleAnimation), with: nil, afterDelay: 0.08)
    }

    @objc func middleAnimation() {
        scale = 0.95
        UIView.animate(withDuration: 0.33) {
            self.imageView.alpha = 0.5
            self.titleLabel.alpha = 0.5
        }
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        layer.setAffineTransform(transform)
        perform(#selector(endSelectAnimation), with: nil, afterDelay: 0.1)
    }

    @objc func endSelectAnimation() {
        scale = 1.0
        UIView.animate(withDuration: 0.33) {
            self.imageView.alpha = 0.5
            self.titleLabel.alpha = 0.5
        }
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        layer.setAffineTransform(transform)
    }
    
    
    func configureCellWith<T>(_ item: T) {
        guard let movie = item as? Movie else {
            print("[e]: Initializing cell with invalid item");
            return
        }
        
        titleLabel.text = movie.title
        
        if let image = movie.mediumCoverImage, let url = URL(string: image) {
            imageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "movie_placeholder"), imageTransition: .crossDissolve(0.33))
        } else {
            imageView.image = UIImage(named: "movie_placeholder")
        }
    }
}
