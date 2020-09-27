//
//  MainTabBarController.swift
//  Popcorn-iOS
//
//  Created by Antique on 14/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import UIKit

class MainTabBarController : UITabBarController {
    var mainMediaCollectionViewController: UINavigationController!
    var mainDownloadsCollectionViewController: UINavigationController!
    var mainWatchlistCollectionViewController: UINavigationController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    func setup() {
        addViewControllers()
        
    }
    
    
    func addViewControllers() {
        let mainMediaFlowLayout = UICollectionViewFlowLayout()
        mainMediaFlowLayout.scrollDirection = .vertical
        
        mainMediaCollectionViewController = UINavigationController(rootViewController: MainMediaCollectionViewController(collectionViewLayout: mainMediaFlowLayout))
        mainMediaCollectionViewController.tabBarItem = UITabBarItem(title: "Movies".localized, image: UIImage(systemName: "film"), tag: 0)
        
        
        let mainWatchlistFlowLayout = UICollectionViewFlowLayout()
        mainWatchlistFlowLayout.scrollDirection = .vertical
        
        mainWatchlistCollectionViewController = UINavigationController(rootViewController: MediaWatchlistCollectionViewController(collectionViewLayout: mainWatchlistFlowLayout))
        mainWatchlistCollectionViewController.tabBarItem = UITabBarItem(title: "Watchlist".localized, image: UIImage(systemName: "book"), tag: 1)
        
        
        let mainDownloadsFlowLayout = UICollectionViewFlowLayout()
        mainDownloadsFlowLayout.scrollDirection = .vertical
        
        mainDownloadsCollectionViewController = UINavigationController(rootViewController: MainDownloadsCollectionViewController(collectionViewLayout: mainDownloadsFlowLayout))
        mainDownloadsCollectionViewController.tabBarItem = UITabBarItem(title: "Downloads".localized, image: UIImage(systemName: "folder"), tag: 2)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateForNetwork(notification:)), name: .flagsChanged, object: nil)
        
        
        viewControllers = [mainMediaCollectionViewController, mainWatchlistCollectionViewController, mainDownloadsCollectionViewController]
    }
    
    
    @objc func updateForNetwork(notification: Notification) {
        switch Network.reachability.status {
            case .unreachable:
                viewControllers = [mainDownloadsCollectionViewController]
            case .wwan:
                viewControllers = [mainMediaCollectionViewController, mainWatchlistCollectionViewController, mainDownloadsCollectionViewController]
            case .wifi:
                viewControllers = [mainMediaCollectionViewController, mainWatchlistCollectionViewController, mainDownloadsCollectionViewController]
        }
    }
}
