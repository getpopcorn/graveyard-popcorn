//
//  Array+Extension.swift
//  PopcornTime
//
//  Created by Jarrod Norwell on 23/5/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    var uniqued: Array {
        var buffer = [Element]()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
    mutating func unique() {
        self = uniqued
    }
    
    
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }
    
    
    func appending(_ items: Element...) -> [Element] {
        return appending(items)
    }
    
    func appending(_ items: [Element]) -> [Element] {
        var new = self
        new.append(contentsOf: items)
        return new
    }
}
