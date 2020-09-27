//
//  StartupNavigationController.swift
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 3/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

class StartupNavigationController : UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let movieFlowLayout = UICollectionViewFlowLayout()
        movieFlowLayout.scrollDirection = .vertical
        let moviesViewController = MoviesCollectionViewController(collectionViewLayout: movieFlowLayout)
        moviesViewController.tabBarItem = UITabBarItem(title: "Movies", image: UIImage(systemName: "film"), tag: 0)

        
        let downloadsFlowLayout = UICollectionViewFlowLayout()
        downloadsFlowLayout.scrollDirection = .vertical
        let downloadsViewController = DownloadsCollectionViewController(collectionViewLayout: downloadsFlowLayout)
        downloadsViewController.tabBarItem = UITabBarItem(title: "Downloads", image: UIImage(systemName: "icloud.and.arrow.down"), tag: 1)
        
        
        let searchViewController = UIViewController()
        searchViewController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        
        
        self.viewControllers = [UINavigationController(rootViewController: moviesViewController), UINavigationController(rootViewController: downloadsViewController), UINavigationController(rootViewController: searchViewController)]
    }
}
