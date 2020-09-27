//
//  HoursMinutesSecondsHelper.swift
//  Popcorn-iOS
//
//  Created by Antique on 14/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation

class HoursMinutesSeconds {
    class func secondsToMinutesSeconds(seconds : Int) -> (minutes : Int , seconds : Int) {
        return (seconds / 60, (seconds % 60))
    }
    
    class func minutesToHoursMinutes(minutes : Int) -> (hours : Int , leftMinutes : Int) {
        return (minutes / 60, (minutes % 60))
    }
}
