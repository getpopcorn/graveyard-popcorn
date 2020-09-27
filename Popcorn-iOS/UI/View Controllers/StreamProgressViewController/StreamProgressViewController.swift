//
//  StreamProgressViewController.swift
//  Popcorn-iOS
//
//  Created by Antique on 21/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Alamofire
import AVFoundation
import AVKit
import Foundation
import PopcornKit
import PopcornTorrent

class StreamProgressViewController : UIViewController {
    var media: Media!
    var torrent = Torrent()
    var player = AVPlayer()
    
    
    var isReady = false
    var videoURL: URL?
    var videoPath: URL?
    var srt: String?
    var shouldUseSubtitles = false
    
    
    var progressView = UIProgressView()
    
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    var loadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    var progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .center
        label.textColor = .tertiaryLabel
        return label
    }()
    
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissStream(sender:))), animated: true)
        
        
        loadingLabel.text = "Loading".localized
        view.addSubview(loadingLabel)
        
        loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        loadingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        
        titleLabel.text = media != nil ? media.title : "Unavailable".localized
        view.addSubview(titleLabel)
        
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: loadingLabel.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressViewStyle = .bar
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .secondarySystemBackground
        view.addSubview(progressView)
        
        progressView.topAnchor.constraint(equalTo: loadingLabel.bottomAnchor, constant: 8).isActive = true
        progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        
        
        PTTorrentStreamer.shared().startStreaming(fromFileOrMagnetLink: torrent.url, progress: { (progress) in
            self.progressView.setProgress(progress.totalProgress*20, animated: true)
            self.loadingLabel.text = String(format: "Loading".localized, " (%.1f%@)", progress.totalProgress*100, "%")
        }, readyToPlay: { (videoFileURL, videoFilePath) in
            //self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Resume".localized, style: .plain, target: self, action: #selector(self.resumeStream(sender:))), animated: true)
                
                
            self.isReady = true
            self.videoPath = videoFilePath
            self.videoURL = videoFileURL
            self.loadingLabel.text = "Ready".localized
                
                
            if videoFileURL.absoluteString.contains(".mp4") {
                self.player = AVPlayer(url: self.videoURL!)
                let playerController = AVPlayerViewController()
                playerController.modalPresentationStyle = .fullScreen
                playerController.player = self.player
                playerController.allowsPictureInPicturePlayback = true
                playerController.delegate = self
                self.player.play()
                    
                self.present(playerController, animated: true, completion: nil)
            } else {
                let vlcController = VLCMediaPlayerViewController()
                vlcController.modalPresentationStyle = .fullScreen
                vlcController.shouldUseSubtitles = self.shouldUseSubtitles
                vlcController.srt = self.srt
                vlcController.url = self.videoURL
                    
                self.present(vlcController, animated: true, completion: nil)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // MARK: viewDidLayoutSubviews()
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        progressView.round(corners: .allCorners, radius: 3, usesBorder: false, borderColor: .clear, borderWidth: 0)
    }
    
    
    // MARK dismissStream(sender: UIBarButtonItem)
    @objc func dismissStream(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = sender
        }
        
        alertController.addAction(UIAlertAction(title: "Stop Stream".localized, style: .destructive, handler: { (action) in
            PTTorrentStreamer.shared().cancelStreamingAndDeleteData(true)
            self.dismiss(animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
}


extension StreamProgressViewController : AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        let currentViewController = navigationController?.visibleViewController
        if currentViewController != playerViewController {
            currentViewController?.present(playerViewController, animated: true, completion: nil)
        }
    }
}
