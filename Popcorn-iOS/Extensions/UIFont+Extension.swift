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
    
    
    func convertPointTo(pixels: CGFloat) -> CGFloat {
        return pixels * 1.33
    }
    
    
    public func withTraits(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits)) ?? UIFontDescriptor(name: UIFont.systemFont(ofSize: self.pointSize).familyName, size: self.pointSize)
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    public var bold : UIFont {
        return withTraits(.traitBold)
    }
}
