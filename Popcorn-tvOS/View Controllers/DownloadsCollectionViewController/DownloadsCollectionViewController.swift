//
//  DownloadsCollectionViewController.swift
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 3/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AVFoundation
import AVKit
import Foundation
import Gzip
import PopcornKit_tvOS
import PopcornTorrent
import UIKit

class DownloadsCollectionViewController : UICollectionViewController {
    // PopcornKit
    var activeDownloads = [PTTorrentDownload]()
    var completedDownloads = [PTTorrentDownload]()
    
    
    var selectedDownload: PTTorrentDownload!
    var media: Media!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        title = "Downloads"
        navigationController?.navigationBar.isTranslucent = false
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DownloadQueueCell.self, forCellWithReuseIdentifier: "DownloadQueueCell")
        collectionView.register(DownloadedCell.self, forCellWithReuseIdentifier: "DownloadedCell")
        
        
        PTTorrentDownloadManager.shared().add(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activeDownloads = PTTorrentDownloadManager.shared().activeDownloads
        completedDownloads = PTTorrentDownloadManager.shared().completedDownloads
        
        reload()
    }
    
    
    func reload() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionViewLayout.invalidateLayout()
        }
    }
    
    
    func reload(_ cell: DownloadQueueCell) {
        UIView.animate(withDuration: 0.33) {
            cell.imageView.alpha = 1.0
            cell.progressView.alpha = 0.0
        }
    }
    
    
    func playbackOptions(download: PTTorrentDownload, cell: UICollectionViewCell) {
        let alertController = UIAlertController(title: "Playback Options", message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Play", style: .default, handler: { (alert) in
            alertController.dismiss(animated: true, completion: nil)
                    
            let path = download.savePath!
            let file = download.fileName!
            
            let fileURL = URL(fileURLWithPath: "\(path)/\(file)")
            if file.contains(".mp4") {
                let player = AVPlayer(url: fileURL)
                let playerController = AVPlayerViewController()
                playerController.modalPresentationStyle = .fullScreen
                playerController.player = player
                player.play()
                
                self.present(playerController, animated: true, completion: nil)
            } else {
                let vlcController = VLCMediaPlayerViewController()
                vlcController.modalPresentationStyle = .fullScreen
                vlcController.torrent = download
                vlcController.url = fileURL
                
                self.present(vlcController, animated: true, completion: nil)
            }
        }))
        
        let savePath = download.savePath!
        let documents = try? FileManager.default.contentsOfDirectory(atPath: "\(savePath)/Subtitles/")
        
        let srts = documents?.filter { ($0 as NSString).pathExtension == "srt" }
        if srts?.count ?? 0 > 0 {
            alertController.addAction(UIAlertAction(title: "Choose Subtitle".localized, style: .default, handler: { (action) in
                let subtitleAlertController = UIAlertController(title: "Available Subtitles".localized, message: nil, preferredStyle: .actionSheet)
                if let popoverPresentationController = subtitleAlertController.popoverPresentationController {
                    popoverPresentationController.sourceView = cell
                }
                
                for srt in srts! {
                    subtitleAlertController.addAction(UIAlertAction(title: (srt as NSString).deletingPathExtension, style: .default, handler: { (action) in
                        let path = download.savePath!
                        let file = download.fileName!
                            
                        let fileURL = URL(fileURLWithPath: "\(path)/\(file)")
                            
                        if !file.contains(".mp4") {
                            let player = AVPlayer(url: fileURL)
                            let playerController = AVPlayerViewController()
                            playerController.modalPresentationStyle = .fullScreen
                            playerController.player = player
                            playerController.addSubtitles().open(fileFromLocal: URL(fileURLWithPath: "\(savePath)/Subtitles/\(srt)"))
                            playerController.player?.play()
                            
                            self.present(playerController, animated: true, completion: nil)
                        } else {
                            let vlcController = VLCMediaPlayerViewController()
                            vlcController.modalPresentationStyle = .fullScreen
                            vlcController.url = fileURL
                            vlcController.shouldUseSubtitles = true
                            vlcController.srt = "\(savePath)/Subtitles/\(srt)"
                            vlcController.torrent = download
                            
                            self.present(vlcController, animated: true, completion: nil)
                        }
                    }))
                }
                
                subtitleAlertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (alert) in
                    subtitleAlertController.dismiss(animated: true, completion: nil)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }))
                
                self.present(subtitleAlertController, animated: true, completion: nil)
            }))
        }
        
        if (download.mediaMetadata["mediaType"] as! Int) == 256 {
            alertController.addAction(UIAlertAction(title: "Download Subtitles".localized, style: .default, handler: { (action) in
                let subtitleAlertController = UIAlertController(title: "Available Subtitles".localized, message: nil, preferredStyle: .actionSheet)
                if let popoverPresentationController = subtitleAlertController.popoverPresentationController {
                    popoverPresentationController.sourceView = cell
                }
                
                for languages in self.media.subtitles {
                    for subtitle in languages.value.sorted(by: { $0.language < $1.language }) {
                        let action = UIAlertAction(title: subtitle.language, style: .default, handler: { (action) in
                            if let actionSubtitle = self.media.subtitles[subtitle.language]?.first {
                                PopcornKit_tvOS.downloadSubtitleFile(actionSubtitle.link, fileName: "\(actionSubtitle.language).gz", downloadDirectory: URL(fileURLWithPath: savePath, isDirectory: true), completion: { (subtitlePath, error) in
                                    guard let subtitlePath = subtitlePath else {
                                        return
                                    }
                                    
                                    self.gunzip(path: subtitlePath, language: actionSubtitle.language)
                                })
                            } else {
                                print("Not a subtitle")
                            }
                        })
                        
                        let health: Health!
                        if subtitle.rating <= 0.2 {
                            health = .bad
                            action.setValue(health.image.withRenderingMode(.alwaysOriginal), forKey: "image")
                        } else if subtitle.rating > 0.2 && subtitle.rating <= 0.5 {
                            health = .medium
                            action.setValue(health.image.withRenderingMode(.alwaysOriginal), forKey: "image")
                        } else if subtitle.rating > 0.5 && subtitle.rating <= 0.8 {
                            health = .good
                            action.setValue(health.image.withRenderingMode(.alwaysOriginal), forKey: "image")
                        } else {
                            health = .excellent
                            action.setValue(health.image.withRenderingMode(.alwaysOriginal), forKey: "image")
                        }
                        subtitleAlertController.addAction(action)
                    }
                }
                
                subtitleAlertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (alert) in
                    subtitleAlertController.dismiss(animated: true, completion: nil)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }))
                
                self.present(subtitleAlertController, animated: true, completion: nil)
            }))
        }
                
        alertController.addAction(UIAlertAction(title: "Broadcast".localized, style: .default, handler: { (alert) in
            alertController.dismiss(animated: true, completion: nil)
            download.play { (videoFileURL, videoFilePath) in
                let alertController = UIAlertController(title: "Now Broadcasting".localized, message: videoFileURL.absoluteString, preferredStyle: .actionSheet)
                if let popoverPresentationController = alertController.popoverPresentationController {
                    popoverPresentationController.sourceView = cell
                }
                        
                alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                }))
                        
                self.present(alertController, animated: true, completion: nil)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler: { (alert) in
            alertController.dismiss(animated: true, completion: nil)
            download.delete()
            self.reload()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (alert) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: gunzip(path: URL, language: String)
    func gunzip(path: URL, language: String) {
        do {
            let uncompressed = try Data(contentsOf: URL(string: path.absoluteString)!).gunzipped()
            do {
                let folderPath = (path.absoluteString as NSString).deletingLastPathComponent
                (folderPath as NSString).replacingOccurrences(of: "file:", with: "")
                
                try uncompressed.write(to: URL(string: "\(folderPath)/\(language).srt")!)
                
                do {
                    try FileManager.default.removeItem(at: URL(string: path.absoluteString)!)
                } catch {
                    print(error.localizedDescription)
                }
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}


extension DownloadsCollectionViewController : UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return activeDownloads.count > 0 ? 2 : 1
    }
        
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if activeDownloads.count > 0 {
            return section == 0 ? activeDownloads.count : completedDownloads.count
        } else {
            return completedDownloads.count
        }
    }
        
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if activeDownloads.count > 0 {
            if indexPath.section == 0 {
                let downloadQueueCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DownloadQueueCell", for: indexPath) as! DownloadQueueCell
                downloadQueueCell.configureCellWith(activeDownloads[indexPath.item])
                return downloadQueueCell
            } else {
                let downloadedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DownloadedCell", for: indexPath) as! DownloadedCell
                downloadedCell.configureCellWith(completedDownloads[indexPath.item])
                return downloadedCell
            }
        } else {
            let downloadedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DownloadedCell", for: indexPath) as! DownloadedCell
            downloadedCell.configureCellWith(completedDownloads[indexPath.item])
            return downloadedCell
        }
    }
        
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if activeDownloads.count > 0 {
            if indexPath.section == 0 {
                let downloadQueueCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DownloadQueueCell", for: indexPath) as! DownloadQueueCell
                downloadQueueCell.startSelectAnimation()
            } else {
                selectedDownload = completedDownloads[indexPath.item]
                
                media = (selectedDownload.mediaMetadata["mediaType"] as! Int) == 256 ? Movie(selectedDownload.mediaMetadata) : Show(selectedDownload.mediaMetadata)
                if (selectedDownload.mediaMetadata["mediaType"] as! Int) == 256 {
                    SubtitlesManager().search(nil, imdbId: media.id, videoFilePath: URL(fileURLWithPath: "\(selectedDownload.savePath!)/\(selectedDownload.fileName!)"), limit: "500") { (subtitles, error) in
                        self.media.subtitles = subtitles
                        self.playbackOptions(download: self.selectedDownload, cell: collectionView.cellForItem(at: indexPath)!)
                    }
                }
            }
        } else {
            selectedDownload = completedDownloads[indexPath.item]
            
            media = (selectedDownload.mediaMetadata["mediaType"] as! Int) == 256 ? Movie(selectedDownload.mediaMetadata) : Show(selectedDownload.mediaMetadata)
            if (selectedDownload.mediaMetadata["mediaType"] as! Int) == 256 {
                SubtitlesManager().search(nil, imdbId: media.id, videoFilePath: URL(fileURLWithPath: "\(selectedDownload.savePath!)/\(selectedDownload.fileName!)"), limit: "500") { (subtitles, error) in
                    self.media.subtitles = subtitles
                    self.playbackOptions(download: self.selectedDownload, cell: collectionView.cellForItem(at: indexPath)!)
                }
            }
        }
    }
        
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
        
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCells: CGFloat = 8
        let width = collectionView.bounds.width
        
        let cellWidth = (width/numberOfCells)-74
            
        return CGSize(width: cellWidth, height: cellWidth*1.65)
    }
}


extension DownloadsCollectionViewController : PTTorrentDownloadManagerListener {
    func torrentStatusDidChange(_ torrentStatus: PTTorrentStatus, for download: PTTorrentDownload) {
        for cell in collectionView.visibleCells {
            if activeDownloads.count > 0 {
                let cell = cell as! DownloadQueueCell
                let indexPath = collectionView.indexPath(for: cell)
                let download = activeDownloads[indexPath!.item]
                
                switch download.downloadStatus {
                    case .downloading:
                        print(download.torrentStatus.totalProgress)
                        cell.progressView.value = CGFloat(download.torrentStatus.totalProgress*100)
                    case .failed:
                        break
                    case .finished:
                        self.reload(cell)
                        break
                    case .paused:
                        break
                    case .processing:
                        break
                    @unknown default:
                        fatalError("Unknown value for downloadStatus")
                }
            }
        }
    }
    
    
    func downloadStatusDidChange(_ downloadStatus: PTTorrentDownloadStatus, for download: PTTorrentDownload) {
        for cell in collectionView.visibleCells {
            if activeDownloads.count > 0 {
                let cell = cell as! DownloadQueueCell
                let indexPath = collectionView.indexPath(for: cell)
                let download = activeDownloads[indexPath!.item]
                
                switch download.downloadStatus {
                    case .downloading:
                        print(download.torrentStatus.totalProgress)
                        cell.progressView.value = CGFloat(download.torrentStatus.totalProgress*100)
                    case .failed:
                        break
                    case .finished:
                        self.reload(cell)
                        break
                    case .paused:
                        break
                    case .processing:
                        break
                    @unknown default:
                        fatalError("Unknown value for downloadStatus")
                }
            }
        }
    }
}
