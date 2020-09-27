//
//  FocusButton.swift
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 3/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

class FocusButton : UIButton {
    // General
    var scale: CGFloat = 1.0
    var usesBlur: Bool = false
    
    var visualEffectView: _UIBackdropView!
    var imageColor: UIColor?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func addBlurView() {
        visualEffectView = _UIBackdropView(privateStyle: 4005)!
        visualEffectView.setBlurQuality("default")
        visualEffectView.setBlurRadius(35)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.isUserInteractionEnabled = false
        addSubview(visualEffectView)
        insertSubview(visualEffectView, at: -1)
        bringSubviewToFront(imageView!)
                
        visualEffectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        struct wrapper {
            static var s_atvMotionEffect = UIMotionEffectGroup()
        }

        coordinator.addCoordinatedAnimations({
            if self.isFocused {
                self.addMotionEffect(wrapper.s_atvMotionEffect)
                self.scale = 1.05
                let transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
                self.layer.setAffineTransform(transform)
                
                
                if !self.usesBlur {
                    UIView.animate(withDuration: 0.33) {
                        self.backgroundColor = .white
                        self.setTitleColor(.black, for: .normal)
                    }
                } else {
                    UIView.animate(withDuration: 0.33) {
                        self.visualEffectView.alpha = 0.0
                        self.backgroundColor = .white
                        self.setTitleColor(.black, for: .normal)
                    }
                }
            } else {
                self.removeMotionEffect(wrapper.s_atvMotionEffect)
                self.scale = 1.0
                let transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
                self.layer.setAffineTransform(transform)
                
                
                if !self.usesBlur {
                    UIView.animate(withDuration: 0.33) {
                        self.backgroundColor = .systemBlue
                        self.setTitleColor(.white, for: .normal)
                    }
                } else {
                    UIView.animate(withDuration: 0.33) {
                        self.visualEffectView.alpha = 1.0
                        self.backgroundColor = .clear
                        self.setTitleColor(.white, for: .normal)
                    }
                }
            }
        }, completion: nil)
    }
}
