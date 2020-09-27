//
//  VLCMediaPlayerViewController.swift
//  Popcorn-iOS
//
//  Created by Antique on 16/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import MediaPlayer
import MobileVLCKit
import PopcornKit
import PopcornTorrent
import UIKit

class VLCMediaPlayerViewController : UIViewController {
    var url: URL!
    var movieView: UIView!
    
    var torrent: PTTorrentDownload!
    var srt: String!
    var shouldUseSubtitles = false
    var mediaPlayer = VLCMediaPlayer()
    
    var closeBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
    var closeButton = BlurredButton(type: .close)
    
    
    var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = .white
        return progressView
    }()
    
    
    var elapsedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        return label
    }()
    
    var remainingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        label.textColor = .secondaryLabel
        return label
    }()

    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let buttonSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 48 : 40
        
        
        movieView = UIView()
        movieView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(movieView)
        
        movieView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        movieView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        movieView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        movieView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        
        closeBlurView.translatesAutoresizingMaskIntoConstraints = false
        closeBlurView.isUserInteractionEnabled = true
        view.addSubview(closeBlurView)
        view.insertSubview(closeBlurView, aboveSubview: movieView)
        
        closeBlurView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        closeBlurView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        closeBlurView.widthAnchor.constraint(equalToConstant: view.bounds.width-40).isActive = true
        closeBlurView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        closeBlurView.contentView.addSubview(progressView)
        
        progressView.topAnchor.constraint(equalTo: closeBlurView.contentView.topAnchor, constant: 16).isActive = true
        progressView.leadingAnchor.constraint(equalTo: closeBlurView.contentView.leadingAnchor, constant: 16).isActive = true
        progressView.trailingAnchor.constraint(equalTo: closeBlurView.contentView.trailingAnchor, constant: -16).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        
        elapsedLabel.text = "00:00:00"
        closeBlurView.contentView.addSubview(elapsedLabel)
        
        elapsedLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 4).isActive = true
        elapsedLabel.leadingAnchor.constraint(equalTo: progressView.leadingAnchor).isActive = true
        
        
        remainingLabel.text = "-00:00:00"
        closeBlurView.contentView.addSubview(remainingLabel)
        
        remainingLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 4).isActive = true
        remainingLabel.trailingAnchor.constraint(equalTo: progressView.trailingAnchor).isActive = true
        
        
        let playButton = UIButton(type: .system)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(togglePlaybackState(sender:)), for: .touchUpInside)
        playButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
        playButton.tintColor = .white
        closeBlurView.contentView.addSubview(playButton)
        
        playButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8).isActive = true
        playButton.centerXAnchor.constraint(equalTo: closeBlurView.contentView.centerXAnchor).isActive = true
        playButton.bottomAnchor.constraint(equalTo: closeBlurView.contentView.bottomAnchor, constant: -8).isActive = true
        playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor).isActive = true
        
        
        let jumpBackButton = UIButton(type: .system)
        jumpBackButton.translatesAutoresizingMaskIntoConstraints = false
        jumpBackButton.addTarget(self, action: #selector(jumpBack), for: .touchUpInside)
        jumpBackButton.setImage(UIImage(systemName: "gobackward.15"), for: .normal)
        jumpBackButton.tintColor = .white
        closeBlurView.contentView.addSubview(jumpBackButton)
        
        jumpBackButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8).isActive = true
        jumpBackButton.bottomAnchor.constraint(equalTo: closeBlurView.contentView.bottomAnchor, constant: -8).isActive = true
        jumpBackButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: 0).isActive = true
        jumpBackButton.widthAnchor.constraint(equalTo: jumpBackButton.heightAnchor).isActive = true
        
        
        let jumpForwardButton = UIButton(type: .system)
        jumpForwardButton.translatesAutoresizingMaskIntoConstraints = false
        jumpForwardButton.addTarget(self, action: #selector(jumpForward), for: .touchUpInside)
        jumpForwardButton.setImage(UIImage(systemName: "goforward.15"), for: .normal)
        jumpForwardButton.tintColor = .white
        closeBlurView.contentView.addSubview(jumpForwardButton)
        
        jumpForwardButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8).isActive = true
        jumpForwardButton.bottomAnchor.constraint(equalTo: closeBlurView.contentView.bottomAnchor, constant: -8).isActive = true
        jumpForwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 0).isActive = true
        jumpForwardButton.widthAnchor.constraint(equalTo: jumpForwardButton.heightAnchor).isActive = true

        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeMedia), for: .touchUpInside)
        //closeButton.setImage(UIImage(systemName: "multiply", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), for: .normal)
        closeButton.tintColor = .white
        view.addSubview(closeButton)
        view.insertSubview(closeButton, aboveSubview: movieView)
        
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
        
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { (timer) in
            if self.mediaPlayer.isPlaying {
                UIView.animate(withDuration: 0.33) {
                    self.closeBlurView.alpha = 0.0
                    self.closeButton.alpha = 0.0
                }
            } else {
                UIView.animate(withDuration: 0.33) {
                    self.closeBlurView.alpha = 1.0
                    self.closeButton.alpha = 1.0
                }
            }
        }
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
        movieView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: viewDidAppear(_ animated: Bool)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let media = VLCMedia(url: url!)
        mediaPlayer.media = media
        mediaPlayer.delegate = self
        mediaPlayer.drawable = movieView
        if shouldUseSubtitles {
            mediaPlayer.addPlaybackSlave(URL(fileURLWithPath: srt), type: .subtitle, enforce: true)
        }
        mediaPlayer.play()
    }
    
    // MARK: viewDidDisappear(_ animated: Bool)
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        if self.isBeingDismissed {
            mediaPlayer.media = nil
            mediaPlayer.delegate = nil
            movieView = nil
        }
    }
    
    // MARK: viewDidLayoutSubviews()
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        closeBlurView.round(corners: .allCorners, radius: 6, usesBorder: false, borderColor: .clear, borderWidth: 0)
        closeButton.round(corners: .allCorners, radius: closeButton.bounds.height/2, usesBorder: false, borderColor: .clear, borderWidth: 0)
        progressView.round(corners: .allCorners, radius: progressView.bounds.height/2, usesBorder: false, borderColor: .clear, borderWidth: 0)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isPortrait {
            
        } else {
            
        }
    }
    
    
    func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    @objc func closeMedia() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func jumpBack() {
        mediaPlayer.jumpBackward(15)
    }
    
    @objc func togglePlaybackState(sender: UIButton) {
        if mediaPlayer.isPlaying {
            mediaPlayer.pause()
            sender.setImage(UIImage(systemName: "play.circle"), for: .normal)
        } else {
            mediaPlayer.play()
            sender.setImage(UIImage(systemName: "pause.circle"), for: .normal)
        }
    }
    
    @objc func jumpForward() {
        mediaPlayer.jumpForward(15)
    }
    
    
    @objc func toggleControls() {
        if closeBlurView.alpha == 1.0 {
            UIView.animate(withDuration: 0.33) {
                self.closeBlurView.alpha = 0.0
                self.closeButton.alpha = 0.0
            }
        } else {
            UIView.animate(withDuration: 0.33) {
                self.closeBlurView.alpha = 1.0
                self.closeButton.alpha = 1.0
            }
        }
    }
}


extension VLCMediaPlayerViewController : VLCMediaPlayerDelegate {
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        let player = aNotification.object as! VLCMediaPlayer
        
        elapsedLabel.text = player.time.stringValue
        remainingLabel.text = player.remainingTime.stringValue
        progressView.setProgress(player.position, animated: true)
    }
}



class SliderBuffer : UISlider {
    let bufferProgress =  UIProgressView(progressViewStyle: .default)
    override init (frame : CGRect) {
        super.init(frame : frame)
    }

    convenience init () {
        self.init(frame:CGRect.zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        self.minimumTrackTintColor = .clear
        self.maximumTrackTintColor = .clear
        bufferProgress.backgroundColor = .clear
        bufferProgress.isUserInteractionEnabled = false
        bufferProgress.progress = 0.0
        bufferProgress.progressTintColor = .white
        bufferProgress.trackTintColor = UIColor.systemGray5.withAlphaComponent(0.5)
        self.addSubview(bufferProgress)
    }
}
