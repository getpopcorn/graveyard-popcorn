//
//  UIView+Extension.swift
//  PopcornTime
//
//  Created by Jarrod Norwell on 22/5/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @nonobjc var parent: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    var recursiveSubviews: [UIView] {
        var subviews = self.subviews.compactMap({$0})
        subviews.forEach { subviews.append(contentsOf: $0.recursiveSubviews) }
        return subviews
    }
    
    func round(corners: UIRectCorner, radius: CGFloat, usesBorder: Bool, borderColor: UIColor, borderWidth: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        
        if usesBorder {
            let borderLayer = CAShapeLayer()
            borderLayer.path = path.cgPath // Reuse the Bezier path
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = borderColor.cgColor
            borderLayer.lineWidth = borderWidth
            borderLayer.frame = bounds
            layer.addSublayer(borderLayer)
        }
        
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func round(radius: CGFloat, shadowColor: UIColor, shadowOffset: CGSize, shadowOpacity: CGFloat, shadowRadius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowPath = path.cgPath
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowOpacity = Float(shadowOpacity)
        shadowLayer.shadowOffset = shadowOffset
        shadowLayer.shadowRadius = shadowRadius
        shadowLayer.masksToBounds = true
        
        layer.mask = shadowLayer
    }
    
    
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
    
    
    func findConstraint(layoutAttribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        if let constraints = superview?.constraints {
            for constraint in constraints where itemMatch(constraint: constraint, layoutAttribute: layoutAttribute) {
                return constraint
            }
        }
        return nil
    }

    func itemMatch(constraint: NSLayoutConstraint, layoutAttribute: NSLayoutConstraint.Attribute) -> Bool {
        if let firstItem = constraint.firstItem as? UIView, let secondItem = constraint.secondItem as? UIView {
            let firstItemMatch = firstItem == self && constraint.firstAttribute == layoutAttribute
            let secondItemMatch = secondItem == self && constraint.secondAttribute == layoutAttribute
            return firstItemMatch || secondItemMatch
        }
        return false
    }
}
