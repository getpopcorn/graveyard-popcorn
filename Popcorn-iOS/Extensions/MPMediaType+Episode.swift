//
//  MPMediaType+Episode.swift
//  PopcornTime
//
//  Created by Jarrod Norwell on 22/5/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import MediaPlayer.MPMediaItem

extension MPMediaType {
    static let episode = MPMediaType(rawValue: 1 << 14)
}
