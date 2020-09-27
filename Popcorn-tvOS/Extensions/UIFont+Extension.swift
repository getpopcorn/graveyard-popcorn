//
//  UIFont+Extension.swift
//  PopcornTime
//
//  Created by Jarrod Norwell on 22/5/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    enum Style: String {
        case bold = "Bold"
        case italic = "Italic"
        case boldItalic = "Bold-Italic"
        case normal = "Normal"
        
        static let arrayValue = [bold, italic, boldItalic, normal]
        
        var localizedString: String {
            return self.rawValue
        }
    }
}
