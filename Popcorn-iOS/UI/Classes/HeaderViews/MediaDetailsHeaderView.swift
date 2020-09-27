//
//  MediaDetailsHeaderView.swift
//  Popcorn-iOS
//
//  Created by Antique on 15/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

class MediaDetailsHeaderView : UICollectionReusableView {
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
        
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32).isActive = true
    }
}
