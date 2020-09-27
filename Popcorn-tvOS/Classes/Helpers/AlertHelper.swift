//
//  AlertHelper.swift
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 16/6/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import AVFoundation
import AVKit
import Foundation
import PopcornKit_tvOS
import PopcornTorrent

class AlertHelper : NSObject {
    class func chooseQuality(media: Media, completion: @escaping (Torrent) -> Void) {
        let alertController = UIAlertController(title: "Choose Quality", message: nil, preferredStyle: .alert)
        
        for torrent in media.torrents {
            let action = UIAlertAction(title: torrent.quality, style: .default) { _ in
                completion(torrent)
            }
            action.setValue(torrent.health.image.withRenderingMode(.alwaysOriginal), forKey: "image")
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        currentViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    
    class func downloadOptions(status: PTTorrentDownloadStatus, download: PTTorrentDownload) {
        let alertController = UIAlertController(title: "Download Options", message: "Pause, resume, stop and save a download.", preferredStyle: .actionSheet)
        
        switch status {
            case .downloading:
                alertController.addAction(UIAlertAction(title: "Pause", style: .default, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.pause()
                }))
                
                alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.save()
                }))
                
                alertController.addAction(UIAlertAction(title: "Stop (Delete)", style: .destructive, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.stop()
                }))
                break
            case .failed:
                alertController.title = "Download Failed"
            case .finished:
                break
            case .paused:
                alertController.addAction(UIAlertAction(title: "Resume", style: .default, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.resume()
                }))
                
                alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.save()
                }))
                
                alertController.addAction(UIAlertAction(title: "Stop (Delete)", style: .destructive, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.stop()
                }))
                break
            case .processing:
                alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.save()
                }))
                
                alertController.addAction(UIAlertAction(title: "Stop (Delete)", style: .destructive, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.stop()
                }))
                break
            @unknown default:
                fatalError("Unknown value for downloadStatus")
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        currentViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    
    @objc class func clearCache() {
        let alertController = UIAlertController(title: "Clear Cache", message: "Are you sure you want to clear the download cache?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
            
            let controller = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            do {
                let size = FileManager.default.folderSize(atPath: NSTemporaryDirectory())
                for path in try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory()) {
                    try FileManager.default.removeItem(atPath: NSTemporaryDirectory() + "/\(path)")
                }
                controller.title = "Successful"
                if size == 0 {
                    controller.message = "Cache was already empty, no disk space was reclaimed.".localized
                } else {
                    controller.message = "Cleaned" + " \(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))."
                }
            } catch {
                controller.title = "Failed"
                controller.message = "Error cleaning cache."
            }
            
            currentViewController()?.present(controller, animated: true)
        }))
        
        currentViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    
    class func showGenre(current: NetworkManager.Genres, completion: @escaping (NetworkManager.Genres) -> Void) {
        let controller = UIAlertController(title: "Genre".localized, message: "Select a genre to filter by.".localized, preferredStyle: .actionSheet)
        
        let handler: ((UIAlertAction) -> Void) = { (handler) in
            completion(NetworkManager.Genres.array.first(where: {$0.string == handler.title!})!)
        }
        
        NetworkManager.Genres.array.sorted(by: {
            $1 != .all && $0.string.localizedStandardCompare($1.string) == .orderedAscending
        }).forEach {
            controller.addAction(UIAlertAction(title: $0.string.localized, style: .default, handler: handler))
        }
        
        controller.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        controller.preferredAction = controller.actions.first(where: {$0.title == current.string})
        
        currentViewController()?.present(controller, animated: true)
    }
    
    class func showMovieFilter(current: MovieManager.Filters, completion: @escaping(MovieManager.Filters) -> Void) {
        let controller = UIAlertController(title: "Filter".localized, message: "Select a filter to sort by.".localized, preferredStyle: .actionSheet)
        
        let handler: ((UIAlertAction) -> Void) = { (handler) in
            completion(MovieManager.Filters.array.first(where: {$0.string == handler.title!})!)
        }
        
        MovieManager.Filters.array.forEach {
            controller.addAction(UIAlertAction(title: $0.string.localized, style: .default, handler: handler))
        }
        
        controller.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        controller.preferredAction = controller.actions.first(where: {$0.title == current.string})
        
        currentViewController()?.present(controller, animated: true)
    }
    
    class func showShowFilter(current: ShowManager.Filters, completion: @escaping(ShowManager.Filters) -> Void) {
        let controller = UIAlertController(title: "Filter".localized, message: "Select a filter to sort by.".localized, preferredStyle: .actionSheet)
        
        let handler: ((UIAlertAction) -> Void) = { (handler) in
            completion(ShowManager.Filters.array.first(where: {$0.string == handler.title!})!)
        }
        
        ShowManager.Filters.array.forEach {
            controller.addAction(UIAlertAction(title: $0.string.localized, style: .default, handler: handler))
        }
        
        controller.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        controller.preferredAction = controller.actions.first(where: {$0.title == current.string})
        
        currentViewController()?.present(controller, animated: true)
    }
    
    
    class func showExternalTorrent() {
        let alertController = UIAlertController(title: "Magnet".localized, message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter magnet link.".localized
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Download".localized, style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        currentViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    
    class func currentViewController() -> UIViewController? {
        if let rootController = UIApplication.shared.windows[0].rootViewController {
            var currentController: UIViewController! = rootController
            while(currentController.presentedViewController != nil) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
}
