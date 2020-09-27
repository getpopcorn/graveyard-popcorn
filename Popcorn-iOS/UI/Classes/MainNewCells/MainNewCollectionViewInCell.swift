//
//  MainNewCollectionViewInCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 14/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import UIKit

class MainNewCollectionViewInCell : UICollectionViewCell {
    var new = [Media]()
    var collectionView: UICollectionView!
    var pageControl: UIPageControl!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pageControl.numberOfPages = new.count
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        pageControl.currentPageIndicatorTintColor = traitCollection.userInterfaceStyle == .light ? .black : .white
    }
    
    
    func setup() {
        addPageControl()
        addCollectionView()
        startTimer()
    }
    
    
    func addPageControl() {
        pageControl = UIPageControl(frame: .zero)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = traitCollection.userInterfaceStyle == .light ? .black : .white
        pageControl.pageIndicatorTintColor = .secondarySystemBackground
        addSubview(pageControl)
        
        pageControl.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        pageControl.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }
    
    
    func addCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.register(MainNewCell.self, forCellWithReuseIdentifier: "MainNewCell")
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -8).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    
    func startTimer() {
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(scrollAutomatically), userInfo: nil, repeats: true)
    }
    
    
    @objc func scrollAutomatically(_ timer1: Timer) {
        if let collectionView = collectionView {
            for cell in collectionView.visibleCells {
                let indexPath: IndexPath? = collectionView.indexPath(for: cell)
                if ((indexPath?.row)! < new.count - 1) {
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(item: (indexPath?.row)! + 1, section: (indexPath?.section)!)

                    collectionView.scrollToItem(at: indexPath1!, at: .right, animated: true)
                }
                else{
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(item: 0, section: (indexPath?.section)!)
                    collectionView.scrollToItem(at: indexPath1!, at: .left, animated: true)
                }

            }
        }
    }
    
    
    func configureWith(new: [Media]) {
        self.new = new
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}


extension MainNewCollectionViewInCell : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let loadingController = LoadingViewController()
        loadingController.media = new[indexPath.item]
        loadingController.modalPresentationStyle = .fullScreen
        
        currentViewController()?.present(loadingController, animated: true, completion: nil)
    }
}


extension MainNewCollectionViewInCell : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return new.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainNewCell", for: indexPath) as! MainNewCell
        newCell.configureFor(media: new[indexPath.item])
        return newCell
    }
}


extension MainNewCollectionViewInCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width
        let height: CGFloat = collectionView.frame.height
        
        return CGSize(width: width, height: height)
    }
}


extension MainNewCollectionViewInCell : UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}
