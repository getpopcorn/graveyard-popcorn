//
//  WatchlistCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 22/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import PopcornTorrent
import UIKit

class WatchlistCell : UICollectionViewCell {
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
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.66).isActive = true
        
        
        addSubview(labelView)
        
        labelView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        labelView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12).isActive = true
        labelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
    }
    
    
    func configureCellWith<T>(_ item: T) {
        guard let media = item as? Media else {
            print("[e]: Initializing cell with invalid item");
            return
        }
        
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            configureForMovie(movie: (media as! Movie))
        } else {
            configureWithShow(show: (media as! Show))
        }
    }
    
    
    func configureForMovie(movie: Movie) {
        labelView.titleLabel.text = movie.title
        labelView.subtitleLabel.text = "\(movie.genres[0].capitalized) • \(movie.year) • "
        
        
        var starTotal: Double = 0
        for star in stride(from: 0, to: Darwin.round(movie.rating)/20, by: 1) {
            labelView.subtitleLabel.text?.append("⭑")
            starTotal = star
        }
        
        while starTotal != 4 {
            labelView.subtitleLabel.text?.append("⭐︎")
            starTotal += 1
        }
        
        
        /*
        if HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours == 1 {
            if HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes == 1 {
                labelView.subtitleLabel.text = "\(movie.genres[0].capitalized) • \(movie.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours) hr \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes) min"
            } else {
                labelView.subtitleLabel.text = "\(movie.genres[0].capitalized) • \(movie.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours) hr \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes) mins"
            }
        } else {
            if HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes == 1 {
                labelView.subtitleLabel.text = "\(movie.genres[0].capitalized) • \(movie.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours) hrs \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes) min"
            } else {
                labelView.subtitleLabel.text = "\(movie.genres[0].capitalized) • \(movie.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours) hrs \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes) mins"
            }
        }*/
        
        
        if let image = movie.mediumBackgroundImage, let url = URL(string: image) {
            self.imageView.af_setImage(withURL: url, placeholderImage: nil, imageTransition: .crossDissolve(0.33))
        } else {
            self.imageView.image = nil
        }
    }
    
    func configureWithShow(show: Show) {
        labelView.titleLabel.text = show.title
        labelView.subtitleLabel.text = "\(show.genres[0].capitalized) • \(show.year) • "
        
        
        var starTotal: Double = 0
        for star in stride(from: 0, to: Darwin.round(show.rating)/20, by: 1) {
            labelView.subtitleLabel.text?.append("⭑")
            starTotal = star
        }
        
        while starTotal != 4 {
            labelView.subtitleLabel.text?.append("⭐︎")
            starTotal += 1
        }
        
        
        if let image = show.mediumBackgroundImage, let url = URL(string: image) {
            self.imageView.af_setImage(withURL: url, placeholderImage: nil, imageTransition: .crossDissolve(0.33))
        } else {
            self.imageView.image = nil
        }
    }
}
