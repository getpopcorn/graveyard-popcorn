//
//  MediaDetailsStretchyHeaderView.swift
//  Popcorn-iOS
//
//  Created by Antique on 14/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AVFoundation
import AVKit
import Foundation
import GSKStretchyHeaderView
import PopcornKit
import PopcornTorrent
import UIKit
import XCDYouTubeKit

class MediaDetailsStretchyHeaderView : GSKStretchyHeaderView  {
    var headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    var descriptionLabel: ReadMoreTextView = {
        let label = ReadMoreTextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 15)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 8
        label.layer.shadowOpacity = 0.08
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.masksToBounds = false
        label.textAlignment = .left
        label.textColor = .white
        label.textContainerInset = .zero
        return label
    }()
    
    var topLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 8
        label.layer.shadowOpacity = 0.08
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.masksToBounds = false
        label.textAlignment = .center
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        return label
    }()
    
    var ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 29)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 8
        label.layer.shadowOpacity = 0.08
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.masksToBounds = false
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    
    var blurView: UIView!
    var media: Media!
    var seasonEpisodes = [Episode]()
    
    var streamButton: UIButton!
    var downloadButton: BlurredButton!
    
    
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
        downloadButton.round(corners: .allCorners, radius: 10, usesBorder: false, borderColor: .clear, borderWidth: 0)
        streamButton.round(corners: .allCorners, radius: 10, usesBorder: false, borderColor: .clear, borderWidth: 0)
        
        let mask = CAGradientLayer()
        mask.frame = headerImageView.bounds
        mask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        mask.startPoint = CGPoint(x: 0.5, y: 0.33)
        mask.endPoint = CGPoint(x: 0.5, y: 1.0)
        headerImageView.layer.mask = mask
    }
    
    
    func setup() {
        backgroundColor = .black
        
        
        contentView.addSubview(headerImageView)
        
        headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        headerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        headerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        headerImageView.heightAnchor.constraint(equalTo: headerImageView.widthAnchor, multiplier: 1.65).isActive = true
        headerImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        
        contentView.addSubview(descriptionLabel)
        
        descriptionLabel.bottomAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: -32).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32).isActive = true
        
        
        downloadButton = BlurredButton(type: .custom)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.addTarget(self, action: #selector(downloadTorrent(sender:)), for: .touchUpInside)
        downloadButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        downloadButton.setTitle("Download".localized, for: .normal)
        downloadButton.setTitleColor(.white, for: .normal)
        contentView.addSubview(downloadButton)
        
        downloadButton.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -20).isActive = true
        downloadButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32).isActive = true
        downloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32).isActive = true
        downloadButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        streamButton = UIButton(type: .custom)
        streamButton.translatesAutoresizingMaskIntoConstraints = false
        streamButton.addTarget(self, action: #selector(streamTorrent(sender:)), for: .touchUpInside)
        streamButton.backgroundColor = .systemBlue
        streamButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        streamButton.setTitle("Stream".localized, for: .normal)
        streamButton.setTitleColor(.white, for: .normal)
        contentView.addSubview(streamButton)
        
        streamButton.bottomAnchor.constraint(equalTo: downloadButton.topAnchor, constant: -8).isActive = true
        streamButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32).isActive = true
        streamButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32).isActive = true
        streamButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        contentView.addSubview(topLabel)
        
        topLabel.bottomAnchor.constraint(equalTo: streamButton.topAnchor, constant: -20).isActive = true
        topLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32).isActive = true
        topLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32).isActive = true
        
        
        //contentView.addSubview(ratingLabel)
        
        //ratingLabel.bottomAnchor.constraint(equalTo: topLabel.topAnchor, constant: -4).isActive = true
        //ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32).isActive = true
        //ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32).isActive = true
        
        
        contentView.addSubview(logoImageView)
        
        logoImageView.bottomAnchor.constraint(equalTo: topLabel.topAnchor, constant: -20).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 47).isActive = true
    }
    
    
    @objc func streamTorrent(sender: UIButton) {
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            AlertHelper.chooseQuality(media: self.media, button: sender) { (torrent) in
                let streamNavController = UINavigationController(rootViewController: StreamProgressViewController())
                streamNavController.modalPresentationStyle = .fullScreen
                    
                (streamNavController.viewControllers[0] as! StreamProgressViewController).media = self.media
                (streamNavController.viewControllers[0] as! StreamProgressViewController).shouldUseSubtitles = false
                (streamNavController.viewControllers[0] as! StreamProgressViewController).torrent = torrent
                self.currentViewController()?.present(streamNavController, animated: true, completion: nil)
            }
        } else {
            AlertHelper.chooseQuality(media: (self.media as! Show).latestUnwatchedEpisode()!, button: sender) { (torrent) in
                let streamNavController = UINavigationController(rootViewController: StreamProgressViewController())
                streamNavController.modalPresentationStyle = .fullScreen
                    
                (streamNavController.viewControllers[0] as! StreamProgressViewController).media = self.media
                (streamNavController.viewControllers[0] as! StreamProgressViewController).shouldUseSubtitles = false
                (streamNavController.viewControllers[0] as! StreamProgressViewController).torrent = torrent
                self.currentViewController()?.present(streamNavController, animated: true, completion: nil)
            }
        }
    }
    
    
    @objc func downloadTorrent(sender: UIButton) {
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            AlertHelper.chooseQuality(media: media, button: sender) { (torrent) in
                PTTorrentDownloadManager.shared().startDownloading(fromFileOrMagnetLink: torrent.url, mediaMetadata: self.media.mediaItemDictionary)
                    
                let alertController = UIAlertController(title: "Download Started".localized, message: nil, preferredStyle: .alert)
                self.currentViewController()?.present(alertController, animated: true, completion: nil)
                    
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            AlertHelper.chooseQuality(media: (self.media as! Show).latestUnwatchedEpisode()!, button: sender) { (torrent) in
                PTTorrentDownloadManager.shared().startDownloading(fromFileOrMagnetLink: torrent.url, mediaMetadata: self.media.mediaItemDictionary)
                    
                let alertController = UIAlertController(title: "Download Started".localized, message: nil, preferredStyle: .alert)
                self.currentViewController()?.present(alertController, animated: true, completion: nil)
                    
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func configureCellWith<T>(_ item: T) {
        guard let media = item as? Media else {
            print("[e]: Initializing cell with invalid item");
            return
        }
        self.media = media
        
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            configureForMovie(movie: (media as! Movie))
        } else {
            configureForShow(show: (media as! Show))
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.33) {
            self.setNeedsLayout()
        }
    }
    
    
    func configureForMovie(movie: Movie) {
        SubtitlesManager().search(nil, imdbId: media.id, videoFilePath: nil, limit: "500") { (subtitles, error) in
            self.media.subtitles = subtitles
        }
        
        
        if HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours == 1 {
            if HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes == 1 {
                topLabel.text = "\(movie.genres[0].capitalized.localized) • \(movie.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours) hr \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes) min"
            } else {
                topLabel.text = "\(movie.genres[0].capitalized.localized) • \(movie.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours) hr \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes) mins"
            }
        } else {
            if HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes == 1 {
                topLabel.text = "\(movie.genres[0].capitalized.localized) • \(movie.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours) hrs \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes) min"
            } else {
                topLabel.text = "\(movie.genres[0].capitalized.localized) • \(movie.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).hours) hrs \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: movie.runtime).leftMinutes) mins"
            }
        }
        
        var starTotal: Double = 0
        ratingLabel.text = ""
        for star in stride(from: 0, to: Darwin.round(movie.rating)/20, by: 1) {
            ratingLabel.text?.append("⭑")
            starTotal = star
        }
        
        while starTotal != 4 {
            ratingLabel.text?.append("⭐︎")
            starTotal += 1
        }
        
        
        TMDBManager.shared.getLogo(forMediaOfType: .movies, id: media.id) { (url, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let image = url, let url = URL(string: image) {
                    self.logoImageView.af_setImage(withURL: url, placeholderImage: nil, imageTransition: .crossDissolve(0.33))
                } else {
                    self.logoImageView.image = nil
                }
            }
        }
        
        descriptionLabel.text = media.summary
        descriptionLabel.maximumNumberOfLines = 3
        descriptionLabel.attributedReadLessText = NSAttributedString(string: "  less", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemBlue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        descriptionLabel.attributedReadMoreText = NSAttributedString(string: "  more", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemBlue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        descriptionLabel.shouldTrim = true
        
        
        if let image = media.largeCoverImage, let url = URL(string: image) {
            headerImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "movie_placeholder"), imageTransition: .crossDissolve(0.33), completion: { (response) in
                (self.currentViewController() as! NavController).updateStatusBar(isLight: (response.value?.getPixelColor(CGPoint(x: 0.5, y: 0)).isLight())!)
                
                self.streamButton.isEnabled = true
                self.downloadButton.isEnabled = true
            })
        } else {
            headerImageView.image = UIImage(named: "movie_placeholder")
            self.streamButton.isEnabled = true
            self.downloadButton.isEnabled = true
        }
    }
    
    func configureForShow(show: Show) {
        streamButton.alpha = 0.66
        downloadButton.alpha = 0.66
        streamButton.isEnabled = false
        downloadButton.isEnabled = false
        
        
        let showRuntime = show.runtime ?? 0
        if HoursMinutesSeconds.minutesToHoursMinutes(minutes: showRuntime).hours == 0 {
            if HoursMinutesSeconds.minutesToHoursMinutes(minutes: showRuntime).leftMinutes == 1 {
                topLabel.text = "\(show.genres[0].capitalized.localized) • \(show.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: showRuntime).leftMinutes) min"
            } else {
                topLabel.text = "\(show.genres[0].capitalized.localized) • \(show.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: showRuntime).leftMinutes) mins"
            }
        } else {
            if HoursMinutesSeconds.minutesToHoursMinutes(minutes: showRuntime).leftMinutes == 1 {
                topLabel.text = "\(show.genres[0].capitalized.localized) • \(show.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: showRuntime).hours) hrs \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: showRuntime).leftMinutes) min"
            } else {
                topLabel.text = "\(show.genres[0].capitalized.localized) • \(show.year) • \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: showRuntime).hours) hrs \(HoursMinutesSeconds.minutesToHoursMinutes(minutes: showRuntime).leftMinutes) mins"
            }
        }
        
        var starTotal: Double = 0
        ratingLabel.text = ""
        for star in stride(from: 0, to: Darwin.round(show.rating)/20, by: 1) {
            ratingLabel.text?.append("⭑")
            starTotal = star
        }
        
        while starTotal != 4 {
            ratingLabel.text?.append("⭐︎")
            starTotal += 1
        }
        
        
        TMDBManager.shared.getLogo(forMediaOfType: .shows, id: media.id) { (url, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let image = url, let url = URL(string: image) {
                    self.logoImageView.af_setImage(withURL: url, placeholderImage: nil, imageTransition: .crossDissolve(0.33))
                } else {
                    self.logoImageView.image = nil
                }
            }
        }
        
        
        descriptionLabel.text = media.summary
        descriptionLabel.maximumNumberOfLines = 3
        descriptionLabel.attributedReadLessText = NSAttributedString(string: "  less", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemBlue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        descriptionLabel.attributedReadMoreText = NSAttributedString(string: "  more", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemBlue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        descriptionLabel.shouldTrim = true
        
        
        if let image = media.largeCoverImage, let url = URL(string: image) {
            headerImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "movie_placeholder"), imageTransition: .crossDissolve(0.33), completion: { (response) in
                (self.currentViewController() as! NavController).updateStatusBar(isLight: (response.value?.getPixelColor(CGPoint(x: 0.5, y: 0)).isLight())!)
            })
        } else {
            headerImageView.image = UIImage(named: "movie_placeholder")
        }
    }
}
