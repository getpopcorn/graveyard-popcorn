//
//  Double+Extension.swift
//  Popcorn-iOS
//
//  Created by Jarrod Norwell on 27/6/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation

extension Double {
    var shortStringRepresentation: String {
        if self.isNaN {
            return "NaN"
        }
        
        if self.isInfinite {
            return "\(self < 0.0 ? "-" : "+")Infinity"
        }
        
        let units = ["", "K", "M"]
        var interval = self
        var i = 0
        while i < units.count - 1 {
            if abs(interval) < 1000.0 {
                break
            }
            
            i += 1
            interval /= 1000.0
        }
        
        return "\(String(format: "%1.*g", Int(log10(abs(interval))) + 2, interval))\(units[i])"
    }
}
