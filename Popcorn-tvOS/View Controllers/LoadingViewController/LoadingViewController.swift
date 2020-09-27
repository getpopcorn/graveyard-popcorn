//
//  LoadingViewController.swift
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 3/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit_tvOS
import UIKit

class LoadingViewController : UIViewController {
    // General
    var activityView: UIActivityIndicatorView!
    
    // PopcornKit
    var media: Media!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    
    func setup() {
        addActivityView()
        addLoadingLabel()
        
        loadMedia()
    }
    
    
    func addActivityView() {
        activityView = UIActivityIndicatorView(style: .medium)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.color = traitCollection.userInterfaceStyle == .light ? .black : .white
        view.addSubview(activityView)
        activityView.startAnimating()
        
        activityView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
    func addLoadingLabel() {
        let loadingLabel = UILabel()
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        loadingLabel.numberOfLines = 2
        loadingLabel.text = "Loading \(media.title)"
        loadingLabel.textAlignment = .center
        loadingLabel.textColor = .label
        view.addSubview(loadingLabel)
        
        loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingLabel.topAnchor.constraint(equalTo: activityView.bottomAnchor, constant: 16).isActive = true
        loadingLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33).isActive = true
    }
    
    
    func loadMedia() {
        if(media.mediaItemDictionary["mediaType"] as! Int) == 256 {
            let movie = media as! Movie
            MediaHelper.loadMovie(id: movie.id) { (movie, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    let viewController = MediaDetailsViewController()
                    viewController.media = movie as! Movie
                    viewController.modalPresentationStyle = .blurOverFullScreen
                           
                           
                    self.dismiss(animated: true) {
                        self.currentViewController()?.present(viewController, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let show = media as! Show
            MediaHelper.loadShow(id: show.id) { (show, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    let viewController = MediaDetailsViewController()
                    viewController.media = show as! Show
                    viewController.modalPresentationStyle = .blurOverFullScreen
                           
                           
                    self.dismiss(animated: true) {
                        self.currentViewController()?.present(viewController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
