//
//  UIViewController+Extension.swift
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 3/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
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
