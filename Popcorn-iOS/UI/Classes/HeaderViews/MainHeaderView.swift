//
//  MainHeaderView.swift
//  Popcorn-iOS
//
//  Created by Antique on 14/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import UIKit

class MainHeaderView : UICollectionReusableView {
    var mainViewController: MainMediaCollectionViewController!
    var titleLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    func setup() {
        addTitleLabel()
    }
    
    
    func addTitleLabel() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .label
        addSubview(titleLabel)
        
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20).isActive = true
    }
    
    
    func addSortButton() {
        let sortButton = UIButton(type: .system)
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        sortButton.addTarget(self, action: #selector(sort(sender:)), for: .touchUpInside)
        sortButton.setTitle("Sort".localized, for: .normal)
        sortButton.setTitleColor(.systemBlue, for: .normal)
        sortButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        addSubview(sortButton)
        
        sortButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        sortButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }
    
    
    @objc func sort(sender: UIButton) {
        if mainViewController.currentType == 0 {
            showMovieFilter(sender: sender, current: mainViewController.currentMovieFilter) { (filter) in
                self.mainViewController.currentMovieFilter = filter
            }
        } else {
            showShowFilter(sender: sender, current: mainViewController.currentShowFilter) { (filter) in
                self.mainViewController.currentShowFilter = filter
            }
        }
    }
    
    
    func showMovieFilter(sender: UIButton, current: MovieManager.Filters, completion: @escaping(MovieManager.Filters) -> Void) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popoverPresentationController = controller.popoverPresentationController {
            popoverPresentationController.sourceView = sender
        }
        
        let handler: ((UIAlertAction) -> Void) = { (handler) in
            completion(MovieManager.Filters.array.first(where: {$0.string.localized == handler.title!})!)
        }
        
        MovieManager.Filters.array.forEach {
            controller.addAction(UIAlertAction(title: $0.string.localized, style: .default, handler: handler))
        }
        
        controller.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        controller.preferredAction = controller.actions.first(where: {$0.title == current.string.localized})
        controller.popoverPresentationController?.sourceView = sender
        
        currentViewController()?.present(controller, animated: true)
    }
    
    func showShowFilter(sender: UIButton, current: ShowManager.Filters, completion: @escaping(ShowManager.Filters) -> Void) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popoverPresentationController = controller.popoverPresentationController {
            popoverPresentationController.sourceView = sender
        }
        
        let handler: ((UIAlertAction) -> Void) = { (handler) in
            completion(ShowManager.Filters.array.first(where: {$0.string.localized == handler.title!})!)
        }
        
        ShowManager.Filters.array.forEach {
            controller.addAction(UIAlertAction(title: $0.string.localized, style: .default, handler: handler))
        }
        
        controller.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        controller.preferredAction = controller.actions.first(where: {$0.title == current.string.localized})
        controller.popoverPresentationController?.sourceView = sender
        
        currentViewController()?.present(controller, animated: true)
    }
}
