//
//  LoadingViewController.swift
//  Popcorn-iOS
//
//  Created by Antique on 14/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import UIKit

class LoadingViewController : UIViewController {
    var media: Media!
    
    
    var loadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        
        let activityView = UIActivityIndicatorView(style: .medium)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.color = traitCollection.userInterfaceStyle == .light ? .black : .white
        view.addSubview(activityView)
        activityView.startAnimating()
        
        activityView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        loadingLabel.text = "Loading".localized
        loadingLabel.text?.append(" \(media.title)")
        view.addSubview(loadingLabel)
        
        loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingLabel.topAnchor.constraint(equalTo: activityView.bottomAnchor, constant: 8).isActive = true
        loadingLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.66).isActive = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            let movie = media as! Movie
            MediaHelper.loadMovie(id: movie.id) { (movie, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    let flowLayout = UICollectionViewFlowLayout()
                    flowLayout.scrollDirection = .vertical
                    
                    let detailsNavController = NavController(rootViewController: MovieDetailsCollectionViewController(collectionViewLayout: flowLayout))
                    (detailsNavController.viewControllers[0] as! MovieDetailsCollectionViewController).media = movie
                    detailsNavController.modalPresentationStyle = .fullScreen
                    
                    self.dismiss(animated: true) {
                        self.currentViewController()?.present(detailsNavController, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let show = media as! Show
            MediaHelper.loadShow(id: show.id) { (show, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    let flowLayout = UICollectionViewFlowLayout()
                    flowLayout.scrollDirection = .vertical
                    
                    let detailsNavController = NavController(rootViewController: MovieDetailsCollectionViewController(collectionViewLayout: flowLayout))
                    (detailsNavController.viewControllers[0] as! MovieDetailsCollectionViewController).media = show
                    detailsNavController.modalPresentationStyle = .fullScreen
                    
                    self.dismiss(animated: true) {
                        self.currentViewController()?.present(detailsNavController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}


extension LoadingViewController {
    // MARK: currentViewController() -> UIViewController?
    func currentViewController() -> UIViewController? {
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
