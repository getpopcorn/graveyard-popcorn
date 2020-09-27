//
//  Media+Extension.swift
//  PopcornTime
//
//  Created by Jarrod Norwell on 24/5/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import MediaPlayer.MPMediaItem
import PopcornTorrent
import PopcornKit_tvOS

extension Media {/*
    func play(fromFileOrMagnetLink url: String, nextEpisodeInSeries nextEpisode: Episode? = nil, loadingViewController: PreloadTorrentViewController, playViewController: UIViewController, progress: Float, loadingBlock: @escaping (PTTorrentStatus, PreloadTorrentViewController) -> Void = { (status, viewController) in
        viewController.progress = status.bufferingProgress
        viewController.speed = Int(status.downloadSpeed)
        viewController.seeds = Int(status.seeds)
        },
        playBlock: @escaping (URL, URL, Media, Episode?, Float, UIViewController, PTTorrentStreamer) -> Void = { (videoFileURL, videoFilePath, media, nextEpisode, progress, viewController, streamer) in
        if let viewController = viewController as? PCTPlayerViewController {
            viewController.play(media, fromURL: videoFileURL, localURL: videoFilePath, progress: progress, nextEpisode: nextEpisode, directory: videoFilePath.deletingLastPathComponent(), streamer: streamer)
        }
        },
        errorBlock: @escaping (String) -> Void,
        finishedLoadingBlock: @escaping (PreloadTorrentViewController, UIViewController) -> Void,
        selectingTorrentBlock: ( (Array<String>) -> Int32)? = nil)
    {
        if hasDownloaded, let download = associatedDownload {
            return download.play { (videoFileURL, videoFilePath) in
                loadingViewController.streamer = download
                playBlock(videoFileURL, videoFilePath, self, nextEpisode, progress, playViewController, download)
                finishedLoadingBlock(loadingViewController, playViewController)
            }
        }
        
        PTTorrentStreamer.shared().cancelStreamingAndDeleteData(false) // Make sure we're not already streaming
        
        if url.hasPrefix("magnet") || (url.hasSuffix(".torrent") && !url.hasPrefix("http")) {
            loadingViewController.streamer = .shared()
            if selectingTorrentBlock != nil {
                PTTorrentStreamer.shared().startStreaming(fromMultiTorrentFileOrMagnetLink: url, progress: { (status) in
                    loadingBlock(status, loadingViewController)
                }, readyToPlay: { (videoFileURL, videoFilePath) in
                    playBlock(videoFileURL, videoFilePath, self, nextEpisode, progress, playViewController, .shared())
                    finishedLoadingBlock(loadingViewController, playViewController)
                }, failure: { error in
                    errorBlock(errorDescription)
                }, selectFileToStream: { torrents in
                    return selectingTorrentBlock!(torrents)
                })
            }else{
                PTTorrentStreamer.shared().startStreaming(fromFileOrMagnetLink: url, progress: { (status) in
                    loadingBlock(status, loadingViewController)
                }, readyToPlay: { (videoFileURL, videoFilePath) in
                    playBlock(videoFileURL, videoFilePath, self, nextEpisode, progress, playViewController, .shared())
                    finishedLoadingBlock(loadingViewController, playViewController)
                }, failure: { error in
                    errorBlock(errorDescription)
                })
            }
        } else {
            PopcornKit.downloadTorrentFile(url, completion: { (url, error) in
                guard let url = url, error == nil else { errorBlock(error!Description); return }
                self.play(fromFileOrMagnetLink: url, nextEpisodeInSeries: nextEpisode, loadingViewController: loadingViewController, playViewController: playViewController, progress: progress, loadingBlock: loadingBlock, playBlock: playBlock, errorBlock: errorBlock, finishedLoadingBlock: finishedLoadingBlock)
            })
        }
    }*/
    
    /*
    #if os(iOS)
        func playOnChromecast(fromFileOrMagnetLink url: String, loadingViewController: PreloadTorrentViewController, playViewController: UIViewController, progress: Float, loadingBlock: @escaping ((PTTorrentStatus, PreloadTorrentViewController) -> Void) = { (status, viewController) in
            viewController.progress = status.bufferingProgress
            viewController.speed = Int(status.downloadSpeed)
            viewController.seeds = Int(status.seeds)
        }, playBlock: @escaping (URL, URL, Media, Episode?, Float, UIViewController, PTTorrentStreamer) -> Void = { (videoFileURL, videoFilePath, media, _, progress, viewController, streamer) in
            guard let viewController = viewController as? CastPlayerViewController else { return }
            viewController.media = media
            viewController.url = videoFileURL
            viewController.streamer = streamer
            viewController.localPathToMedia = videoFilePath
            viewController.directory = videoFilePath.deletingLastPathComponent()
            viewController.startPosition = TimeInterval(progress)
        }, errorBlock: @escaping (String) -> Void,
            finishedLoadingBlock: @escaping (PreloadTorrentViewController, UIViewController) -> Void)
        {
            self.play( fromFileOrMagnetLink: url, loadingViewController: loadingViewController, playViewController: playViewController, progress: progress, loadingBlock: loadingBlock, playBlock: playBlock, errorBlock: errorBlock, finishedLoadingBlock: finishedLoadingBlock)
        }
    #endif*/
    
    func getSubtitles(forId id: String? = nil, orWithFilePath: URL? = nil, forLang:String? = nil,completion: @escaping (Dictionary<String, [Subtitle]>) -> Void) {
        let id = id ?? self.id
        if let filePath = orWithFilePath {
            SubtitlesManager.shared.search(preferredLang: "el", videoFilePath: filePath){ (subtitles, _) in
                completion(subtitles)
            }
        } else if let `self` = self as? Episode, !id.hasPrefix("tt"), let show = self.show {
            TraktManager.shared.getEpisodeMetadata(show.id, episodeNumber: self.episode, seasonNumber: self.season) { (episode, _) in
                if let imdb = episode?.imdbId { return self.getSubtitles(forId: imdb, completion: completion) }
                
                SubtitlesManager.shared.search(self) { (subtitles, _) in
                    completion(subtitles)
                }
            }
        } else {
            SubtitlesManager.shared.search(imdbId: id) { (subtitles, _) in
                completion(subtitles)
            }
        }
    }
    
    /// The download, either completed or downloading, that is associated with this media object.
    var associatedDownload: PTTorrentDownload? {
        let array = PTTorrentDownloadManager.shared().activeDownloads + PTTorrentDownloadManager.shared().completedDownloads
        return array.first(where: {($0.mediaMetadata[MPMediaItemPropertyPersistentID] as? String) == self.id})
    }
    
    
    /// Boolean value indicating whether the media is currently downloading.
    var isDownloading: Bool {
        return PTTorrentDownloadManager.shared().activeDownloads.first(where: {($0.mediaMetadata[MPMediaItemPropertyPersistentID] as? String) == self.id}) != nil
    }
    
    /// Boolean value indicating whether the media has been downloaded.
    var hasDownloaded: Bool {
        return PTTorrentDownloadManager.shared().completedDownloads.first(where: {($0.mediaMetadata[MPMediaItemPropertyPersistentID] as? String) == self.id}) != nil
    }
}
