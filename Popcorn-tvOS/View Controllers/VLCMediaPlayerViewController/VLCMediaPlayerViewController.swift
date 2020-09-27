//
//  VLCMediaPlayerViewController.swift
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 4/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import MediaPlayer
import TVVLCKit
import PopcornKit_tvOS
import PopcornTorrent
import UIKit

class VLCMediaPlayerViewController : UIViewController {
    var url: URL!
    var movieView: UIView!
    
    var torrent: PTTorrentDownload!
    var srt: String!
    var shouldUseSubtitles: Bool = false
    var mediaPlayer = VLCMediaPlayer()

    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    
    func setup() {
        addMovieView()
    }
    
    
    func addMovieView() {
        movieView = UIView()
        movieView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(movieView)
        
        movieView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        movieView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        movieView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        movieView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    
    // MARK: viewDidAppear(_ animated: Bool)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let media = VLCMedia(url: url!)
        mediaPlayer.media = media
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
            movieView = nil
        }
    }
}
