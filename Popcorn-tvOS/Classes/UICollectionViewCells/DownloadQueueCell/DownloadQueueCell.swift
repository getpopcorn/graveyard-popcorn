//
//  DownloadQueueCell.swift
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

class DownloadQueueCell : UICollectionViewCell {
    var selectTrans: UIFocusAnimationCoordinator?
    var scale: CGFloat = 0.0
    
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var progressView: MBCircularProgressBarView = {
        let progressView = MBCircularProgressBarView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.backgroundColor = .clear
        progressView.maxValue = 100
        progressView.emptyCapType = 1
        progressView.emptyLineColor = UIColor.white.withAlphaComponent(0.33)
        progressView.emptyLineStrokeColor = .clear
        progressView.emptyLineWidth = 5
        progressView.progressAngle = 100
        progressView.progressColor = .white
        progressView.progressLineWidth = 5
        progressView.progressStrokeColor = .clear
        progressView.showUnitString = false
        progressView.showValueString = false
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
        round(corners: .allCorners, radius: 8, usesBorder: false, borderColor: .clear, borderWidth: 0)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        struct wrapper {
            static let s_atvMotionEffect = UIMotionEffectGroup()
            
        }

        coordinator.addCoordinatedAnimations({
            if self.isFocused {
                self.addMotionEffect(wrapper.s_atvMotionEffect)
                self.layer.shadowOpacity = 0.5;
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
        imageView.alpha = 0.33
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        
        addSubview(progressView)
        
        progressView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        progressView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        progressView.heightAnchor.constraint(equalTo: progressView.widthAnchor).isActive = true
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
