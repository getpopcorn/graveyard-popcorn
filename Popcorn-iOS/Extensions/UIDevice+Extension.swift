//
//  UIDevice+Extension.swift
//  PopcornTime
//
//  Created by Jarrod Norwell on 11/6/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    var hasCellularCapabilites: Bool {
        var addrs: UnsafeMutablePointer<ifaddrs>?
        var cursor: UnsafeMutablePointer<ifaddrs>?
        
        defer { freeifaddrs(addrs) }
        
        guard getifaddrs(&addrs) == 0 else { return false }
        cursor = addrs
        
        while cursor != nil {
            guard
                let utf8String = cursor?.pointee.ifa_name,
                let name = NSString(utf8String: utf8String),
                name == "pdp_ip0"
                else {
                    cursor = cursor?.pointee.ifa_next
                    continue
            }
            return true
        }
        return false
    }
}
