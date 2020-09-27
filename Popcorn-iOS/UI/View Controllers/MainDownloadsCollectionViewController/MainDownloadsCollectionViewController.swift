//
//  MainDownloadsCollectionViewController.swift
//  Popcorn-iOS
//
//  Created by Antique on 16/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AVFoundation
import AVKit
import Foundation
import GCDWebServer
import Gzip
import MobileVLCKit
import PopcornKit
import PopcornTorrent
import UIKit


class MainDownloadsCollectionViewController : UICollectionViewController {
    var queue = [PTTorrentDownload]()
    var downloads = [[PTTorrentDownload]]()
    var selectedDownload: PTTorrentDownload!
    var segmentControl = UISegmentedControl()
    var media: Media!
    var currentType: Int = 0 // 0 = queue, 1 = downloaded
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        PTTorrentDownloadManager.shared().add(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if PTTorrentDownloadManager.shared().activeDownloads.count > 0 {
            segmentControl.selectedSegmentIndex = 0
            currentType = 0
        } else {
            segmentControl.selectedSegmentIndex = 1
            currentType = 1
        }
        
        configureFor(type: currentType)
        load()
    }
    
    
    func setup() {
        setupNavigationBar()
        setupCollectionView()
    }
    
    
    func setupNavigationBar() {
        title = "Downloads".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(openSettings)), animated: true)
        
        
        segmentControl.insertSegment(withTitle: "Queue".localized, at: 0, animated: true)
        segmentControl.insertSegment(withTitle: "Downloaded".localized, at: 1, animated: true)
        segmentControl.addTarget(self, action: #selector(segmentControlDidChange(sender:)), for: .valueChanged)
        if PTTorrentDownloadManager.shared().activeDownloads.count > 0 {
            segmentControl.selectedSegmentIndex = 0
            currentType = 0
        } else {
            segmentControl.selectedSegmentIndex = 1
            currentType = 1
        }
        navigationItem.titleView = segmentControl
    }
    
    
    func setupCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.register(MediaQueueDownloadCell.self, forCellWithReuseIdentifier: "MediaQueueDownloadCell")
        collectionView.register(MediaDownloadedCell.self, forCellWithReuseIdentifier: "MediaDownloadedCell")
        collectionView.register(NoContentCell.self, forCellWithReuseIdentifier: "NoContentCell")
        collectionView.register(MainHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MainHeaderView")
    }
    
    
    @objc func segmentControlDidChange(sender: UISegmentedControl) {
        load()
        currentType = currentType == 0 ? 1 : 0
        configureFor(type: currentType)
    }
    
    
    func configureFor(type: Int) {
        if type == 0 {
            tabBarController?.tabBar.items![2].image = UIImage(systemName: "folder.badge.plus")
        } else {
            tabBarController?.tabBar.items![2].image = UIImage(systemName: "folder")
        }
    }
    
    
    func humanReadableByteCount(bytes: Int) -> String {
        if (bytes < 1000) {
            return "\(bytes) B"
        }
        
        let exp = Int(log2(Double(bytes)) / log2(1000.0))
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        let number = Double(bytes) / pow(1000, Double(exp))
        
        return String(format: "%.1f %@", number, unit)
    }
    
    
    @objc func load() {
        queue = PopcornTorrent.PTTorrentDownloadManager.shared().activeDownloads
        let movies = PTTorrentDownloadManager.shared().completedDownloads.filter({ ($0.mediaMetadata["mediaType"] as! Int) == 256 }).sorted { (one, two) -> Bool in
            return (one.mediaMetadata["title"] as! String) < (two.mediaMetadata["title"] as! String)
        }
        let episodes = PTTorrentDownloadManager.shared().completedDownloads.filter({ ($0.mediaMetadata["mediaType"] as! Int) != 256 })
        downloads = [movies, episodes]
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    func playbackOptions(download: PTTorrentDownload, cell: UICollectionViewCell, useSubtitles: Bool) {
        let alertController = UIAlertController(title: self.media.title, message: nil, preferredStyle: .actionSheet)
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = cell
        }
        
        
        alertController.addAction(UIAlertAction(title: "Play".localized, style: .default, handler: { (alert) in
            alertController.dismiss(animated: true, completion: nil)
                    
            let path = download.savePath!
            let file = download.fileName!
            
            let fileURL = URL(fileURLWithPath: "\(path)/\(file)")
            if file.contains(".mp4") {
                let player = AVPlayer(url: fileURL)
                let playerController = AVPlayerViewController()
                playerController.modalPresentationStyle = .fullScreen
                playerController.player = player
                playerController.allowsPictureInPicturePlayback = true
                playerController.delegate = self
                player.play()
                
                self.present(playerController, animated: true, completion: nil)
            } else {
                let vlcController = VLCMediaPlayerViewController()
                vlcController.modalPresentationStyle = .fullScreen
                vlcController.url = fileURL
                vlcController.torrent = download
                
                self.present(vlcController, animated: true, completion: nil)
            }
        }))
        
        
        if useSubtitles {
            let savePath = download.savePath!
            let documents = try? FileManager.default.contentsOfDirectory(atPath: "\(savePath)/Subtitles/")
            
            let srts = documents?.filter { ($0 as NSString).pathExtension == "srt" }
            if srts?.count ?? 0 > 0 {
                alertController.addAction(UIAlertAction(title: "Choose Subtitle".localized, style: .default, handler: { (action) in
                    let subtitleAlertController = UIAlertController(title: self.media.title, message: nil, preferredStyle: .actionSheet)
                    if let popoverPresentationController = subtitleAlertController.popoverPresentationController {
                        popoverPresentationController.sourceView = cell
                    }
                    
                    for srt in srts! {
                        if UserDefaults.standard.value(forKey: "defaultLanguage") as? String == (srt as NSString).deletingPathExtension {
                            let path = download.savePath!
                            let file = download.fileName!
                                
                            let fileURL = URL(fileURLWithPath: "\(path)/\(file)")
                                
                            if file.contains(".mp4") {
                                let player = AVPlayer(url: fileURL)
                                let playerController = AVPlayerViewController()
                                playerController.modalPresentationStyle = .fullScreen
                                playerController.player = player
                                playerController.addSubtitles().open(fileFromLocal: URL(fileURLWithPath: "\(savePath)/Subtitles/\(srt)"))
                                playerController.allowsPictureInPicturePlayback = true
                                playerController.delegate = self
                                playerController.player?.play()
                                
                                self.present(playerController, animated: true, completion: nil)
                            } else {
                                let vlcController = VLCMediaPlayerViewController()
                                vlcController.modalPresentationStyle = .fullScreen
                                vlcController.url = fileURL
                                vlcController.torrent = download
                                
                                self.present(vlcController, animated: true, completion: nil)
                            }
                        } else {
                            subtitleAlertController.addAction(UIAlertAction(title: (srt as NSString).deletingPathExtension, style: .default, handler: { (action) in
                                let path = download.savePath!
                                let file = download.fileName!
                                    
                                let fileURL = URL(fileURLWithPath: "\(path)/\(file)")
                                    
                                if file.contains(".mp4") {
                                    let player = AVPlayer(url: fileURL)
                                    let playerController = AVPlayerViewController()
                                    playerController.modalPresentationStyle = .fullScreen
                                    playerController.player = player
                                    playerController.addSubtitles().open(fileFromLocal: URL(fileURLWithPath: "\(savePath)/Subtitles/\(srt)"))
                                    playerController.allowsPictureInPicturePlayback = true
                                    playerController.delegate = self
                                    playerController.player?.play()
                                    
                                    self.present(playerController, animated: true, completion: nil)
                                } else {
                                    let vlcController = VLCMediaPlayerViewController()
                                    vlcController.modalPresentationStyle = .fullScreen
                                    vlcController.url = fileURL
                                    vlcController.torrent = download
                                    
                                    self.present(vlcController, animated: true, completion: nil)
                                }
                            }))
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
            
            if (download.mediaMetadata["mediaType"] as! Int) == 256 {
                alertController.addAction(UIAlertAction(title: "Download Subtitles".localized, style: .default, handler: { (action) in
                    let subtitleAlertController = UIAlertController(title: self.media.title, message: nil, preferredStyle: .actionSheet)
                    if let popoverPresentationController = subtitleAlertController.popoverPresentationController {
                        popoverPresentationController.sourceView = cell
                    }
                    
                    
                    let languages = self.media.subtitles.sorted { (arg0, arg1) -> Bool in
                        let (_, value) = arg1
                        let (_, value2) = arg0
                        return value[0].language == value2[0].language ? value[0].rating > value2[0].rating : value[0].language > value2[0].language
                    }
                    
                    var filtered = [Subtitle]()
                    let language = UserDefaults.standard.string(forKey: "defaultLanguage")
                    let quality = UserDefaults.standard.double(forKey: "minimumSubtitleRating")
                    print(quality)
                    _ = languages.filter({ (arg0) in
                        let (_, value) = arg0
                        value.forEach({ (subtitle) in
                            if language != "None" {
                                if subtitle.rating >= quality && subtitle.language == language && !filtered.contains(subtitle) {
                                    filtered.append(subtitle)
                                }
                            } else {
                                if subtitle.rating >= quality && !filtered.contains(subtitle) {
                                    filtered.append(subtitle)
                                }
                            }
                        })
                        return true
                    })
                    
                    
                    for subtitle in filtered {
                        //for subtitle in language.value {
                            let action = UIAlertAction(title: "\(subtitle.language) (\(String(format: "%.0f", ceil(subtitle.rating)))/10)", style: .default, handler: { (action) in
                                if let actionSubtitle = self.media.subtitles[subtitle.language]?.first {
                                    PopcornKit.downloadSubtitleFile(actionSubtitle.link, fileName: "\(actionSubtitle.language).gz", downloadDirectory: URL(fileURLWithPath: savePath, isDirectory: true), completion: { (subtitlePath, error) in
                                        guard let subtitlePath = subtitlePath else {
                                            return
                                        }
                                        
                                        ZippyHelper.gunzip(path: subtitlePath, language: actionSubtitle.language, completion: { (subtitle) in
                                            
                                        })
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
                        //}
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
            self.load()
        }))
        
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (alert) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    @objc func openSettings() {
        let settingsViewController = UINavigationController(rootViewController: SettingsViewController())
        settingsViewController.modalPresentationStyle = .fullScreen
        
        present(settingsViewController, animated: true, completion: nil)
    }
}


extension MainDownloadsCollectionViewController : UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return segmentControl.selectedSegmentIndex == 0 ? queue.count : 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segmentControl.selectedSegmentIndex == 0 ? queue.count : downloads[section].count > 0 ? downloads[section].count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if segmentControl.selectedSegmentIndex == 0 {
            let queueCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaQueueDownloadCell", for: indexPath) as! MediaQueueDownloadCell
            queueCell.configureCellWith(queue[indexPath.item])
            
            return queueCell
        } else {
            if downloads[indexPath.section].count > 0 {
                let downloadedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDownloadedCell", for: indexPath) as! MediaDownloadedCell
                downloadedCell.configureCellWith(downloads[indexPath.section][indexPath.item])
                
                return downloadedCell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoContentCell", for: indexPath) as! NoContentCell
                cell.noContentLabel.text = indexPath.section == 0 ? "No Movies Downloaded".localized : "No Episodes Downloaded".localized
                return cell
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if segmentControl.selectedSegmentIndex == 0 {
            AlertHelper.downloadOptions(status: queue[indexPath.item].downloadStatus, download: queue[indexPath.item], controller: self, button: collectionView.cellForItem(at: indexPath)!)
        } else {
            if downloads[indexPath.section].count > 0 {
                selectedDownload = downloads[indexPath.section][indexPath.item]
                
                media = (selectedDownload.mediaMetadata["mediaType"] as! Int) == 256 ? Movie(selectedDownload.mediaMetadata) : Episode(selectedDownload.mediaMetadata)
                if (selectedDownload.mediaMetadata["mediaType"] as! Int) == 256 {
                    SubtitlesManager().search(nil, imdbId: media.id, videoFilePath: URL(fileURLWithPath: "\(selectedDownload.savePath!)/\(selectedDownload.fileName!)"), limit: "500") { (subtitles, error) in
                        self.media.subtitles = subtitles
                        self.playbackOptions(download: self.selectedDownload, cell: collectionView.cellForItem(at: indexPath)!, useSubtitles: true)
                    }
                } else {
                    (media.mediaItemDictionary["mediaType"] as! Int) == 256 ? WatchedlistManager<Movie>.movie.add((media as! Movie).id) : WatchedlistManager<Episode>.episode.add((media as! Episode).id)
                    playbackOptions(download: selectedDownload, cell: collectionView.cellForItem(at: indexPath)!, useSubtitles: false)
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice().userInterfaceIdiom == .phone {
            return iPhone_collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        } else {
            return iPad_collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
    }
    
    
    func iPad_collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 27
        let width = collectionView.frame.width
        let cellWidth = (width/3) - padding
        
        return CGSize(width: cellWidth, height: 72)
    }
    
    func iPhone_collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 40
        let width = collectionView.frame.width
        let cellWidth = width - padding
        
        return CGSize(width: cellWidth, height: segmentControl.selectedSegmentIndex == 0 ? 72 : downloads[indexPath.section].count > 0 ? 72 : 48)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let mainHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MainHeaderView", for: indexPath) as! MainHeaderView
        switch indexPath.section {
            case 0:
                mainHeaderView.titleLabel.text = "Movies".localized
            case 1:
                mainHeaderView.titleLabel.text = "Episodes".localized
            default:
                mainHeaderView.titleLabel.text = ""
            }
        return mainHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: segmentControl.selectedSegmentIndex == 0 ? 0 : 40)
    }
}


extension MainDownloadsCollectionViewController : PTTorrentDownloadManagerListener {
    func torrentStatusDidChange(_ torrentStatus: PTTorrentStatus, for download: PTTorrentDownload) {
        for cell in collectionView.visibleCells {
            if segmentControl.selectedSegmentIndex == 0 {
                let cell = cell as! MediaQueueDownloadCell
                let indexPath = collectionView.indexPath(for: cell)
                let download = queue[indexPath!.item]
                
                
                let currentProgress = CGFloat(download.torrentStatus.totalProgress)
                switch download.downloadStatus {
                    case .downloading:
                        let downloadSize = download.fileSize.numberValue.intValue
                        let downloadedAmount = download.totalDownloaded.numberValue.intValue
                        let downloadSpeed = torrentStatus.downloadSpeed
                        //let minutes = HoursMinutesSeconds.secondsToMinutesSeconds(seconds: (downloadSize-downloadedAmount)/Int(downloadSpeed)).minutes
                        //let seconds = HoursMinutesSeconds.secondsToMinutesSeconds(seconds: (downloadSize-downloadedAmount)/Int(downloadSpeed)).seconds
                        
                        
                        if UIDevice().userInterfaceIdiom == .phone {
                            cell.labelView.subtitleLabel.text = "\(humanReadableByteCount(bytes: downloadedAmount)) of \(humanReadableByteCount(bytes: downloadSize))".localized
                        } else {
                            cell.labelView.subtitleLabel.text = "\(humanReadableByteCount(bytes: downloadedAmount)) of \(humanReadableByteCount(bytes: downloadSize)) (\(humanReadableByteCount(bytes: Int(downloadSpeed)))/s)".localized
                        }
                        cell.progressView.updateProgress(CGFloat(download.torrentStatus.totalProgress))
                        cell.progressView.progressTintColor = .systemBlue
                    case .failed:
                        cell.labelView.titleLabel.text = download.mediaMetadata["title"] as? String
                        cell.labelView.subtitleLabel.text = "Failed".localized
                        cell.progressView.updateProgress(currentProgress)
                        cell.progressView.progressTintColor = .systemRed
                    case .finished:
                        cell.labelView.titleLabel.text = download.mediaMetadata["title"] as? String
                        cell.labelView.subtitleLabel.text = "Finished".localized
                        cell.progressView.updateProgress(1.0)
                        cell.progressView.progressTintColor = .systemGreen
                    
                        if let data = cell.imageView.image?.pngData(),
                            !FileManager.default.fileExists(atPath: download.savePath!.appending("/artwork.png")) {
                            do {
                                try data.write(to: URL(fileURLWithPath: download.savePath!.appending("/artwork.png")))
                            } catch {
                                print("error saving file:", error)
                            }
                        }
                    case .paused:
                        cell.labelView.titleLabel.text = download.mediaMetadata["title"] as? String
                        cell.labelView.subtitleLabel.text = "Paused".localized
                        cell.progressView.updateProgress(currentProgress)
                        cell.progressView.progressTintColor = .systemBlue
                    case .processing:
                        cell.labelView.titleLabel.text = download.mediaMetadata["title"] as? String
                        cell.labelView.subtitleLabel.text = "Processing".localized
                        cell.progressView.updateProgress(0.0)
                        cell.progressView.progressTintColor = .tertiarySystemBackground
                    @unknown default:
                        fatalError("Unknown value for downloadStatus")
                }
            }
        }
    }
    
    func downloadStatusDidChange(_ downloadStatus: PTTorrentDownloadStatus, for download: PTTorrentDownload) {
        for cell in collectionView.visibleCells {
            if segmentControl.selectedSegmentIndex == 0 {
                let cell = cell as! MediaQueueDownloadCell
                let indexPath = collectionView.indexPath(for: cell)
                let download = queue[indexPath!.item]
                
                
               let currentProgress = CGFloat(download.torrentStatus.totalProgress)
                switch download.downloadStatus {
                    case .downloading:
                        let downloadSize = download.fileSize.numberValue.intValue
                        let downloadedAmount = download.totalDownloaded.numberValue.intValue
                        let downloadSpeed = download.torrentStatus.downloadSpeed
                        //let minutes = HoursMinutesSeconds.secondsToMinutesSeconds(seconds: (downloadSize-downloadedAmount)/Int(downloadSpeed)).minutes
                        //let seconds = HoursMinutesSeconds.secondsToMinutesSeconds(seconds: (downloadSize-downloadedAmount)/Int(downloadSpeed)).seconds
                        
                        
                        if UIDevice().userInterfaceIdiom == .phone {
                            cell.labelView.subtitleLabel.text = "\(humanReadableByteCount(bytes: downloadedAmount)) of \(humanReadableByteCount(bytes: downloadSize)) (\(humanReadableByteCount(bytes: Int(downloadSpeed)))/s)".localized
                        } else {
                            cell.labelView.subtitleLabel.text = "\(humanReadableByteCount(bytes: downloadedAmount)) of \(humanReadableByteCount(bytes: downloadSize))".localized
                        }
                        cell.progressView.updateProgress(CGFloat(download.torrentStatus.totalProgress))
                        cell.progressView.progressTintColor = .systemBlue
                    case .failed:
                        cell.labelView.titleLabel.text = download.mediaMetadata["title"] as? String
                        cell.labelView.subtitleLabel.text = "Failed".localized
                        cell.progressView.updateProgress(currentProgress)
                        cell.progressView.progressTintColor = .systemRed
                    case .finished:
                        cell.labelView.titleLabel.text = download.mediaMetadata["title"] as? String
                        cell.labelView.subtitleLabel.text = "Finished".localized
                        cell.progressView.updateProgress(1.0)
                        cell.progressView.progressTintColor = .systemGreen
                    
                        if let data = cell.imageView.image?.pngData(),
                            !FileManager.default.fileExists(atPath: download.savePath!.appending("/artwork.png")) {
                            do {
                                try data.write(to: URL(fileURLWithPath: download.savePath!.appending("/artwork.png")))
                            } catch {
                                print("error saving file:", error)
                            }
                        }
                    case .paused:
                        cell.labelView.titleLabel.text = download.mediaMetadata["title"] as? String
                        cell.labelView.subtitleLabel.text = "Paused".localized
                        cell.progressView.updateProgress(currentProgress)
                        cell.progressView.progressTintColor = .systemBlue
                    case .processing:
                        cell.labelView.titleLabel.text = download.mediaMetadata["title"] as? String
                        cell.labelView.subtitleLabel.text = "Processing".localized
                        cell.progressView.updateProgress(0.0)
                        cell.progressView.progressTintColor = .tertiarySystemBackground
                    @unknown default:
                        fatalError("Unknown value for downloadStatus")
                }
            }
        }
    }
}


extension MainDownloadsCollectionViewController : AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        let currentViewController = navigationController?.visibleViewController
        if currentViewController != playerViewController {
            currentViewController?.present(playerViewController, animated: true, completion: nil)
        }
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error) {
        print(error.localizedDescription)
    }
}
