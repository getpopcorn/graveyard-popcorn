//
//  UINavigationController+Extension.swift
//  Popcorn-iOS
//
//  Created by Jarrod Norwell on 1/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    func setNavigationControllerTransparent(transparent: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.33 : 0) {
            if transparent {
                self.navigationBar.setBackgroundImage(UIImage(), for: .default)
                self.navigationBar.shadowImage = UIImage()
                self.navigationBar.isTranslucent = true
                self.navigationBar.backgroundColor = .clear
                self.view.backgroundColor = .clear
            } else {
                self.navigationBar.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.33)
                self.navigationBar.setBackgroundImage(nil, for: .default)
                self.navigationBar.shadowImage = self.from(color: .opaqueSeparator)
            }
        }
    }
    
    
    func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}


class NavController : UINavigationController {
    var isLight = false
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if isLight {
            return .darkContent
        } else {
            return .lightContent
        }
    }
    
    func updateStatusBar(isLight: Bool) {
        self.isLight = isLight
        setNeedsStatusBarAppearanceUpdate()
    }
}
