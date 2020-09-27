//
//  MediaDetailsViewController.swift
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 3/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit_tvOS
import PopcornTorrent
import UIKit

class MediaDetailsViewController : UIViewController {
    // General
    var contentView: UIView!
    var blurredImageView: UIImageView!
    var coverImageView: UIImageView!
    
    var downloadButton: FocusButton!
    var streamButton: FocusButton!
    
    var titleLabel: UILabel!
    var descriptionLabel: UITextView!
    
    // PopcornKit
    var media: Media!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureWith(media: media)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.round(corners: .allCorners, radius: 8, usesBorder: false, borderColor: .clear, borderWidth: 0)
        coverImageView.round(corners: .allCorners, radius: 4, usesBorder: false, borderColor: .clear, borderWidth: 0)
        
        downloadButton.round(corners: .allCorners, radius: 4, usesBorder: false, borderColor: .clear, borderWidth: 0)
        streamButton.round(corners: .allCorners, radius: 4, usesBorder: false, borderColor: .clear, borderWidth: 0)
    }
    
    
    func setup() {
        addContentView()
        addHintLabel()
        addBlurredImageView()
        addBlurView()
        addCoverImageView()
        
        addButtons()
        addTitleLabel()
        addDescriptionLabel()
    }
    
    
    func addContentView() {
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.66).isActive = true
        contentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.66).isActive = true
    }
    
    
    func addHintLabel() {
        let hintLabel = UILabel()
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.textAlignment = .center
        view.addSubview(hintLabel)
        
        
        let startAttributedString = NSMutableAttributedString(string: "Press ", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.33),
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .subheadline)
        ])
        
        let menuAttributedString = NSMutableAttributedString(string: "MENU", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .subheadline)
        ])
        
        let endAttributedString = NSMutableAttributedString(string: " to dismiss this view.", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.33),
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .subheadline)
        ])
        
        let combine = NSMutableAttributedString()
        combine.append(startAttributedString)
        combine.append(menuAttributedString)
        combine.append(endAttributedString)
        hintLabel.attributedText = combine
        
        hintLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 16).isActive = true
        hintLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    
    func addBlurredImageView() {
        blurredImageView = UIImageView()
        blurredImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(blurredImageView)
        contentView.sendSubviewToBack(blurredImageView)
        
        blurredImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        blurredImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        blurredImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        blurredImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    
    func addBlurView() {
        let blurEffectView = _UIBackdropView(privateStyle: 4005)!
        blurEffectView.setBlurQuality("default")
        blurEffectView.setBlurRadius(35)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurredImageView.addSubview(blurEffectView)
        
        blurEffectView.topAnchor.constraint(equalTo: blurredImageView.topAnchor).isActive = true
        blurEffectView.leadingAnchor.constraint(equalTo: blurredImageView.leadingAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: blurredImageView.bottomAnchor).isActive = true
        blurEffectView.trailingAnchor.constraint(equalTo: blurredImageView.trailingAnchor).isActive = true
    }
    
    
    func addCoverImageView() {
        coverImageView = UIImageView()
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(coverImageView)
        
        coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40).isActive = true
        coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        coverImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40).isActive = true
        coverImageView.widthAnchor.constraint(equalTo: coverImageView.heightAnchor, multiplier: 0.66).isActive = true
    }
    
    
    func addButtons() {
        downloadButton = FocusButton(type: .custom)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.addTarget(self, action: #selector(downloadTorrent), for: .primaryActionTriggered)
        downloadButton.addBlurView()
        downloadButton.titleLabel?.font = UIFont.systemFont(ofSize: 38, weight: .medium)
        downloadButton.setTitle("Download", for: .normal)
        downloadButton.setTitleColor(.white, for: .normal)
        downloadButton.usesBlur = true
        contentView.addSubview(downloadButton)
        
        downloadButton.heightAnchor.constraint(equalToConstant: 86).isActive = true
        downloadButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 40).isActive = true
        downloadButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40).isActive = true
        downloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
        
        
        streamButton = FocusButton(type: .custom)
        streamButton.translatesAutoresizingMaskIntoConstraints = false
        streamButton.addTarget(self, action: #selector(streamTorrent), for: .primaryActionTriggered)
        streamButton.backgroundColor = .systemBlue
        streamButton.titleLabel?.font = UIFont.systemFont(ofSize: 38, weight: .medium)
        streamButton.setTitle("Stream", for: .normal)
        streamButton.setTitleColor(.white, for: .normal)
        streamButton.usesBlur = false
        contentView.addSubview(streamButton)
        
        streamButton.heightAnchor.constraint(equalToConstant: 86).isActive = true
        streamButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 40).isActive = true
        streamButton.bottomAnchor.constraint(equalTo: downloadButton.topAnchor, constant: -16).isActive = true
        streamButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
    }
    
    
    func addTitleLabel() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)
        
        titleLabel.topAnchor.constraint(equalTo: coverImageView.topAnchor, constant: 40).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 40).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
    }
    
    
    func addDescriptionLabel() {
        descriptionLabel = UITextView()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        descriptionLabel.textContainer.lineBreakMode = .byTruncatingTail
        descriptionLabel.textContainer.maximumNumberOfLines = 6
        descriptionLabel.textAlignment = .left
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.33)
        descriptionLabel.textContainerInset = .zero
        descriptionLabel.textContainer.lineFragmentPadding = 0
        contentView.addSubview(descriptionLabel)
        
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: streamButton.topAnchor, constant: -40).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
    }
    
    
    @objc func streamTorrent() {
        AlertHelper.chooseQuality(media: self.media) { (torrent) in
            let streamNavController = UINavigationController(rootViewController: StreamProgressViewController())
            streamNavController.modalPresentationStyle = .blurOverFullScreen
                
            (streamNavController.viewControllers[0] as! StreamProgressViewController).media = self.media
            (streamNavController.viewControllers[0] as! StreamProgressViewController).torrent = torrent
            self.currentViewController()?.present(streamNavController, animated: true, completion: nil)
        }
    }
    
    
    @objc func downloadTorrent() {
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            AlertHelper.chooseQuality(media: media) { (torrent) in
                PTTorrentDownloadManager.shared().startDownloading(fromFileOrMagnetLink: torrent.url, mediaMetadata: self.media.mediaItemDictionary)
                    
                let alertController = UIAlertController(title: "Download Started", message: nil, preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                    
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func configureWith(media: Media) {
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            configureWith(movie: media)
        }
    }
    
    func configureWith(movie: Media) {
        guard let movie = movie as? Movie else {
            print("[MediaDetailsViewController.configureWith(movie:)]: Error validating item.");
            return
        }
        
        titleLabel.text = movie.title
        descriptionLabel.text = movie.summary
        
        
        if let blurredImage = movie.mediumBackgroundImage, let url = URL(string: blurredImage) {
            blurredImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "movie_placeholder"), imageTransition: .crossDissolve(0.33))
        } else {
            blurredImageView.image = UIImage(named: "movie_placeholder")
        }
        
        
        if let coverImage = movie.mediumCoverImage, let url = URL(string: coverImage) {
            coverImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "movie_placeholder"), imageTransition: .crossDissolve(0.33))
        } else {
            coverImageView.image = UIImage(named: "movie_placeholder")
        }
    }
}
