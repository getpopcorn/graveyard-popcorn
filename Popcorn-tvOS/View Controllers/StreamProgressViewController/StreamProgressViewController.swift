//
//  StreamProgressViewController.swift
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 4/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Alamofire
import AVFoundation
import AVKit
import Foundation
import PopcornKit_tvOS
import PopcornTorrent

class StreamProgressViewController : UIViewController {
    // General
    var contentView: UIView!
    var blurredImageView: UIImageView!
    var coverImageView: UIImageView!
    
    var resumeButton: FocusButton!
    
    var titleLabel: UILabel!
    var descriptionLabel: UITextView!
    var progressLabel: UILabel!
    
    // PopcornKit
    var media: Media!
    var torrent = Torrent()
    var player = AVPlayer()
    
    var isReady = false
    var videoURL: URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureWith(media: media)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PTTorrentStreamer.shared().cancelStreamingAndDeleteData(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.round(corners: .allCorners, radius: 8, usesBorder: false, borderColor: .clear, borderWidth: 0)
        coverImageView.round(corners: .allCorners, radius: 4, usesBorder: false, borderColor: .clear, borderWidth: 0)
        
        resumeButton.round(corners: .allCorners, radius: 4, usesBorder: false, borderColor: .clear, borderWidth: 0)
    }
    
    
    func setup() {
        addContentView()
        addHintLabel()
        addBlurredImageView()
        addBlurView()
        addCoverImageView()
        
        addButton()
        addTitleLabel()
        addProgressLabel()
        addDescriptionLabel()
        
        startDownloading()
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
        
        let endAttributedString = NSMutableAttributedString(string: " to cancel the download and dismiss this view.", attributes: [
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
        let blurEffectView = _UIBackdropView(style: 4005)!
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
    
    
    func addButton() {
        resumeButton = FocusButton(type: .custom)
        resumeButton.translatesAutoresizingMaskIntoConstraints = false
        //resumeButton.addTarget(self, action: #selector(downloadTorrent), for: .primaryActionTriggered)
        resumeButton.addBlurView()
        resumeButton.isEnabled = false
        resumeButton.titleLabel?.font = UIFont.systemFont(ofSize: 38, weight: .medium)
        resumeButton.setTitle("Resume", for: .normal)
        resumeButton.setTitleColor(.white, for: .normal)
        resumeButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        contentView.addSubview(resumeButton)
        
        resumeButton.heightAnchor.constraint(equalToConstant: 86).isActive = true
        resumeButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 40).isActive = true
        resumeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40).isActive = true
        resumeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
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
    
    
    func addProgressLabel() {
        progressLabel = UILabel()
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        progressLabel.text = "Processing"
        progressLabel.textAlignment = .right
        progressLabel.textColor = .white
        contentView.addSubview(progressLabel)
        
        progressLabel.bottomAnchor.constraint(equalTo: resumeButton.topAnchor, constant: -16).isActive = true
        progressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
    }
    
    
    func addDescriptionLabel() {
        descriptionLabel = UITextView()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        descriptionLabel.text = "Your stream is now loading, depending on network connectivity and torrent location this could take 2-10 minutes. Please keep this view open while Popcorn downloads the content. The stream will open automatically when it is ready to play."
        descriptionLabel.textAlignment = .left
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.33)
        descriptionLabel.textContainer.lineBreakMode = .byTruncatingTail
        descriptionLabel.textContainer.lineFragmentPadding = 0
        descriptionLabel.textContainer.maximumNumberOfLines = 7
        descriptionLabel.textContainerInset = .zero
        contentView.addSubview(descriptionLabel)
        
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: progressLabel.topAnchor, constant: -40).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
    }
    
    
    func startDownloading() {
        PTTorrentStreamer.shared().startStreaming(fromFileOrMagnetLink: torrent.url, progress: { (progress) in
            self.progressLabel.text = String(format: "Loading (%.1f%@)", (progress.totalProgress*100)*10, "%")
        }, readyToPlay: { (videoFileURL, videoFilePath) in
            self.isReady = true
            self.videoURL = videoFileURL
            
            self.resumeButton.isEnabled = true
            
            
            if self.videoURL!.absoluteString.contains(".mp4") {
                self.player = AVPlayer(url: self.videoURL!)
                let playerController = AVPlayerViewController()
                playerController.modalPresentationStyle = .fullScreen
                playerController.player = self.player
                self.player.play()
                
                self.present(playerController, animated: true, completion: nil)
            } else {
                let vlcController = VLCMediaPlayerViewController()
                vlcController.modalPresentationStyle = .fullScreen
                vlcController.shouldUseSubtitles = false
                vlcController.url = self.videoURL
                
                self.present(vlcController, animated: true, completion: nil)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func configureWith(media: Media) {
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            configureWith(movie: media)
        }
    }
    
    func configureWith(movie: Media) {
        guard let movie = movie as? Movie else {
            print("[StreamProgressViewController.configureWith(movie:)]: Error validating item.");
            return
        }
        
        titleLabel.text = "Loading \(movie.title)"
        
        
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
