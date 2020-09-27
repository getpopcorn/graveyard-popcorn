//
//  MainGenresCollectionViewInCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 14/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import UIKit

class MainGenresCollectionViewInCell : UICollectionViewCell {
    var movieGenres = [NetworkManager.MovieGenres]()
    var showGenres = [NetworkManager.ShowGenres]()
    var collectionView: UICollectionView!
    var mainViewController: MainMediaCollectionViewController!
    var type: Int = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    func setup() {
        addCollectionView()
    }

    
    func addCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MainGenreCell.self, forCellWithReuseIdentifier: "MainGenreCell")
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    
    func configureWith(movieGenres: [NetworkManager.MovieGenres]) {
        self.movieGenres = movieGenres
        type = 0
        DispatchQueue.main.async {
            self.collectionView.reloadSections(IndexSet(0 ..< 0))
        }
    }
    
    
    func configureWith(showGenres: [NetworkManager.ShowGenres]) {
        self.showGenres = showGenres
        type = 1
        DispatchQueue.main.async {
            self.collectionView.reloadSections(IndexSet(0 ..< 0))
        }
    }
}


extension MainGenresCollectionViewInCell : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if mainViewController.currentType == 0 {
            mainViewController.currentMovieGenre = movieGenres[indexPath.item]
        } else {
            mainViewController.currentShowGenre = showGenres[indexPath.item]
        }
    }
}


extension MainGenresCollectionViewInCell : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return type == 0 ? movieGenres.count : showGenres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let genreCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainGenreCell", for: indexPath) as! MainGenreCell
        genreCell.titleLabel.text = type == 0 ? movieGenres[indexPath.item].string.localized : showGenres[indexPath.item].string.localized
        return genreCell
    }
}


extension MainGenresCollectionViewInCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                let padding: CGFloat = 60
                let width = collectionView.frame.width
                let cellWidth = width - padding
                let cellsForOrientation: CGFloat = 2.25
        
                return CGSize(width: cellWidth/cellsForOrientation, height: collectionView.frame.height-40)
            case .pad:
                let padding: CGFloat = 80
                let width = collectionView.frame.width
                let cellWidth = width - padding
                let cellsForOrientation: CGFloat = 6
        
                return CGSize(width: cellWidth/cellsForOrientation, height: collectionView.frame.height-40)
            default:
                return .zero
        }
    }
}
