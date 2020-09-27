//
//  AlertHelper.swift
//  Popcorn-iOS
//
//  Created by Antique on 16/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import PopcornTorrent
import UIKit

class AlertHelper : NSObject {
    class func chooseQuality(media: Media, button: UIButton, completion: @escaping (Torrent) -> Void) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = button
        }
        
        for torrent in media.torrents.sorted(by: { $0.quality < $1.quality }) {
            let action = UIAlertAction(title: "\(torrent.quality ?? "N/A") • (\(torrent.size ?? "N/A"))", style: .default) { _ in
                completion(torrent)
            }
            action.setValue(torrent.health.image.withRenderingMode(.alwaysOriginal), forKey: "image")
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        
        currentViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    
    class func chooseQuality(media: Media, barButton: UIBarButtonItem, completion: @escaping (Torrent) -> Void) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = barButton
        }
        
        for torrent in media.torrents.sorted(by: { $0.quality < $1.quality }) {
            let action = UIAlertAction(title: "\(torrent.quality ?? "N/A") • (\(torrent.size ?? "N/A"))", style: .default) { _ in
                completion(torrent)
            }
            action.setValue(torrent.health.image.withRenderingMode(.alwaysOriginal), forKey: "image")
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        
        currentViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    
    class func downloadOptions(status: PTTorrentDownloadStatus, download: PTTorrentDownload, controller: MainDownloadsCollectionViewController, button: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = button
        }
        
        switch status {
            case .downloading:
                alertController.addAction(UIAlertAction(title: "Pause".localized, style: .default, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.pause()
                }))
                
                alertController.addAction(UIAlertAction(title: "Save".localized, style: .default, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.save()
                }))
                
                alertController.addAction(UIAlertAction(title: "Stop (Delete)".localized, style: .destructive, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.stop()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5) {
                        controller.collectionView.reloadData()
                    }
                }))
                break
            case .failed:
                alertController.title = "Download Failed".localized
            case .finished:
                break
            case .paused:
                alertController.addAction(UIAlertAction(title: "Resume".localized, style: .default, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.resume()
                }))
                
                alertController.addAction(UIAlertAction(title: "Save".localized, style: .default, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.save()
                }))
                
                alertController.addAction(UIAlertAction(title: "Stop (Delete)".localized, style: .destructive, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.stop()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5) {
                        controller.collectionView.reloadData()
                    }
                }))
                break
            case .processing:
                alertController.addAction(UIAlertAction(title: "Save".localized, style: .default, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.save()
                }))
                
                alertController.addAction(UIAlertAction(title: "Stop (Delete)".localized, style: .destructive, handler: { (alert) in
                    alertController.dismiss(animated: true, completion: nil)
                    download.stop()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5) {
                        controller.collectionView.reloadData()
                    }
                }))
                break
            @unknown default:
                fatalError("Unknown value for downloadStatus")
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { (alert) in
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
    
    
    class func alert(title: String, message: String, actions: [UIAlertAction], style: UIAlertController.Style) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alertController.addAction(action)
        }
        return alertController
    }
}
