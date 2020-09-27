//
//  Show+Extension.swift
//  PopcornTime
//
//  Created by Jarrod Norwell on 29/5/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit_tvOS

extension Show {
    func latestUnwatchedEpisode(from episodes: [Episode]? = nil) -> Episode? {
        let episodes = episodes ?? self.episodes
        guard episodes.filter({$0.show == self}).count == episodes.count else {
            return nil
        }
        
        let manager = WatchedlistManager<Episode>.episode
        
        let currentlyWatchingEpisodes = episodes.filter({( manager.currentProgress($0.id) > 0.0) || ($0.isWatched) })
        var latestCurrentlyWatchingEpisodesBySeason: [Episode] = []
        
        for season in seasonNumbers {
            guard let last = currentlyWatchingEpisodes.filter({$0.season == season}).sorted(by: {$0.episode < $1.episode}).last else {
                continue
            }
            latestCurrentlyWatchingEpisodesBySeason.append(last)
        }
        
        let latest = latestCurrentlyWatchingEpisodesBySeason.sorted(by: {$0.season < $1.season}).last
        
        if let episode = latest, episode.isWatched {
            if let next = episodes.filter({ episode.season == $0.season }).filter({ $0.episode == (episode.episode + 1) }).first {
                return next
            } else if let next = episodes.filter({ $0.season == (episode.season + 1) }).sorted(by: { $0.episode < $1.episode }).first {
                return next
            } else if let first = latestCurrentlyWatchingEpisodesBySeason.sorted(by: { $0.season < $1.season }).filter({ !$0.isWatched }).first, first != latest {
                return first
            }
            return nil
        }
        return latest
    }
}
