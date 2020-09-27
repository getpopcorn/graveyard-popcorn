//
//  DownloadCell.swift
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 16/6/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AlamofireImage
import Foundation
import MBCircularProgressBar
import PopcornKit_tvOS
import PopcornTorrent
import UIKit

class DownloadedCell : UICollectionViewCell {
    var scale: CGFloat = 0.0
    
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
                let transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
                self.layer.setAffineTransform(transform)
            } else {
                self.removeMotionEffect(wrapper.s_atvMotionEffect)
                self.layer.shadowOpacity = 0.25;
                self.layer.shadowRadius = 8.0;
                self.layer.shadowOffset = CGSize(width: 0, height: 0);
                self.scale = 1.0
                let transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
                self.layer.setAffineTransform(transform)
            }
        }, completion: nil)
    }
    
    
    func setup() {
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    
    func startSelectAnimation() {
        scale = 1.05
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        layer.setAffineTransform(transform)
        perform(#selector(middleAnimation), with: nil, afterDelay: 0.08)
    }

    @objc func middleAnimation() {
        scale = 0.95
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        layer.setAffineTransform(transform)
        perform(#selector(endSelectAnimation), with: nil, afterDelay: 0.1)
    }

    @objc func endSelectAnimation() {
        scale = 1.0
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        layer.setAffineTransform(transform)
    }
    
    
    func configureCellWith<T>(_ item: T) {
        guard let media = item as? PTTorrentDownload else {
            print("[e]: Initializing cell with invalid item");
            return
        }
        
        
        if let image = media.mediaMetadata["artwork"], let url = URL(string: image as! String) {
            self.imageView.af_setImage(withURL: url, placeholderImage: nil, imageTransition: .crossDissolve(0.33))
        } else {
            self.imageView.image = nil
        }
    }
}
