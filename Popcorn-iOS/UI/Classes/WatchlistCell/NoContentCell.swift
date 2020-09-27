//
//  NoContentCell.swift
//  Popcorn-iOS
//
//  Created by Antique on 23/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit
import PopcornTorrent
import UIKit

class NoContentCell : UICollectionViewCell {
    var noContentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    
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
        round(corners: .allCorners, radius: 10, usesBorder: false, borderColor: .clear, borderWidth: 0)
    }
    
    
    func setup() {
        backgroundColor = .secondarySystemBackground
        
        
        addSubview(noContentLabel)
        
        noContentLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        noContentLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        noContentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
        noContentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = true
    }
}
