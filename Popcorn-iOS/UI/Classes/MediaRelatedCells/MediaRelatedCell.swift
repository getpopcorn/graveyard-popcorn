//
//  MediaRelatedCell.swift
//  Popcorn-iOS
//
//  Created by Jarrod Norwell on 28/6/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit

class MediaRelatedCell : UICollectionViewCell {
    var shadowView = UIView()
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    var mediaLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        return label
    }()
    
    var mediaNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .left
        label.textColor = .label
        return label
    }()
    
    var mediaDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 4
        label.textAlignment = .left
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
        imageView.round(corners: .allCorners, radius: 10, usesBorder: false, borderColor: .clear, borderWidth: 0)
        shadowView.round(radius: 10, shadowColor: .black, shadowOffset: CGSize(width: 0, height: 0.5), shadowOpacity: 0.08, shadowRadius: 10)
    }
    
    
    func setup() {
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(shadowView)
        
        shadowView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        shadowView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        shadowView.heightAnchor.constraint(equalToConstant: 141).isActive = true
        shadowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        
        
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: shadowView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor).isActive = true
        
        
        addSubview(mediaLabel)
        
        mediaLabel.topAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: 8).isActive = true
        mediaLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        mediaLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        
        
        addSubview(mediaNameLabel)
        
        mediaNameLabel.topAnchor.constraint(equalTo: mediaLabel.bottomAnchor, constant: 8).isActive = true
        mediaNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        mediaNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        
        
        addSubview(mediaDescriptionLabel)
        
        mediaDescriptionLabel.topAnchor.constraint(equalTo: mediaNameLabel.bottomAnchor, constant: 8).isActive = true
        mediaDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        mediaDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
    }
    
    
    func configureCellWith<T>(_ item: T) {
        guard let media = item as? Media else {
            print("[e]: Initializing cell with invalid item");
            return
        }
        
        
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            configureForMovie(movie: (media as! Movie))
        } else {
            configureForShow(show: (media as! Show))
        }
        
        
        if let image = media.mediumBackgroundImage, let url = URL(string: image) {
            self.imageView.af_setImage(withURL: url, placeholderImage: nil, imageTransition: .crossDissolve(0.33))
        } else {
            self.imageView.image = nil
        }
    }
    
    
    func configureForMovie(movie: Movie) {
        if HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours == 1 {
            if HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes == 1 {
                mediaLabel.text = "\(movie.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours) hr \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes) min • "
            } else {
                mediaLabel.text = "\(movie.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours) hr \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes) mins • "
            }
        } else {
            if HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes == 1 {
                mediaLabel.text = "\(movie.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours) hrs \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes) min • "
            } else {
                mediaLabel.text = "\(movie.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours) hrs \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes) mins • "
            }
        }
        mediaNameLabel.text = movie.title
        mediaDescriptionLabel.text = movie.summary
        
        var starTotal: Double = 0
        for star in stride(from: 0, to: Darwin.round(movie.rating)/20, by: 1) {
            mediaLabel.text?.append("⭑")
            starTotal = star
        }
        
        while starTotal != 4 {
            mediaLabel.text?.append("⭐︎")
            starTotal += 1
        }
    }
    
    func configureForShow(show: Show) {
        mediaLabel.text = "\(show.network ?? "Unknown Network") • \(show.year) • "
        mediaNameLabel.text = show.title
        mediaDescriptionLabel.text = show.summary
        
        
        var starTotal: Double = 0
        for star in stride(from: 0, to: Darwin.round(show.rating)/20, by: 1) {
            mediaLabel.text?.append("⭑")
            starTotal = star
        }
        
        while starTotal != 4 {
            mediaLabel.text?.append("⭐︎")
            starTotal += 1
        }
    }
}
