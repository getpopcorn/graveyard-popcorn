//
//  MediaHelper.swift
//  Popcorn-tvOS
//
//  Created by Jarrod Norwell on 16/6/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation
import PopcornKit_tvOS

class MediaHelper : NSObject {
    class func loadMovie(id: String, completion: @escaping (Media?, NSError?) -> Void) {
        PopcornKit_tvOS.getMovieInfo(id) { (movie, error) in
            guard var movie = movie else {
                completion(nil, error)
                return
            }
            let group = DispatchGroup()
                
            group.enter()
            TraktManager.shared.getRelated(movie) {arg1,_ in
                movie.related = arg1
                
                group.leave()
            }
            
            group.enter()
            TraktManager.shared.getPeople(forMediaOfType: .movies, id: movie.id) {arg1,arg2,_ in
                movie.actors = arg1
                movie.crew = arg2
                
                group.leave()
            }
            
            group.notify(queue: .main) {
                completion(movie, nil)
            }
        }
    }
    
    class func loadShow(id: String, completion: @escaping (Media?, NSError?) -> Void) {
        PopcornKit_tvOS.getShowInfo(id) { (show, error) in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard var show = show, let _ = show.latestUnwatchedEpisode()?.season ?? show.seasonNumbers.first else {
                let error = NSError(domain: "com.antique.popcorntime.error", code: -243, userInfo: [NSLocalizedDescriptionKey: "There are no seasons available for the selected show. Please try again later."])
                completion(nil, error)
                return
            }
            
            let group = DispatchGroup()
            
            
            group.enter()
            ShowManager.shared.getInfo(id) { (arg1, error) in
                if let error = error {
                    completion(nil, error)
                    return
                } else {
                    show.genres = arg1!.genres
                    group.leave()
                }
            }
            
            group.enter()
            TraktManager.shared.getRelated(show) {arg1,_ in
                show.related = arg1
                
                group.leave()
            }
            group.enter()
            TraktManager.shared.getPeople(forMediaOfType: .shows, id: show.id) {arg1,arg2,_ in
                show.actors = arg1
                show.crew = arg2
                
                group.leave()
            }
            
            group.enter()
            loadEpisodeMetadata(for: show) { episodes in
                show.episodes = episodes
                group.leave()
            }
            
            group.notify(queue: .main) {
                completion(show, nil)
            }
        }
    }
    
    
    class func loadEpisodeMetadata(for show: Show, completion: @escaping ([Episode]) -> Void) {
        let group = DispatchGroup()
        
        var episodes = [Episode]()
        
        for var episode in show.episodes {
            group.enter()
            TMDBManager.shared.getEpisodeScreenshots(forShowWithImdbId: show.id, orTMDBId: show.tmdbId, season: episode.season, episode: episode.episode, completion: { (tmdbId, image, error) in
                if let image = image { episode.largeBackgroundImage = image }
                if let tmdbId = tmdbId { episode.show?.tmdbId = tmdbId }
                episodes.append(episode)
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            episodes.sort(by: { $0.episode < $1.episode })
            completion(episodes)
        }
    }
}
