//
//  MediaRatingCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 21/8/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import UIKit

class MediaRatingCell : UICollectionViewCell {
    var background: UIView!
    var progressView: UIProgressView!
    
    
    var ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .right
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
        background.round(corners: .allCorners, radius: 10, usesBorder: false, borderColor: .clear, borderWidth: 0)
        progressView.round(corners: .allCorners, radius: 10, usesBorder: false, borderColor: .clear, borderWidth: 0)
    }
    
    
    func setup() {
        background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = .secondarySystemBackground
        self.addSubview(background)
        
        background.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        background.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
        background.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        background.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = true
        
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .secondarySystemBackground
        progressView.progressTintColor = .systemBlue
        background.addSubview(progressView)
        
        progressView.topAnchor.constraint(equalTo: background.topAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: background.leadingAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: background.bottomAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: background.trailingAnchor).isActive = true
        
        
        progressView.addSubview(ratingLabel)
        
        ratingLabel.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -20).isActive = true
        ratingLabel.centerYAnchor.constraint(equalTo: background.centerYAnchor).isActive = true
    }
    
    
    func setProgress(progress: Float) {
        progressView.setProgress(progress/100, animated: false)
        ratingLabel.text = "\(progress/10)/10"
    }
}
