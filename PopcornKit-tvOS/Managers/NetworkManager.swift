import Foundation
import Alamofire

public struct Trakt {
    static let apiKey = "6ebd7f7434c2d923c83b01489b6ca4bcaae37f0a2696f95a15f35a3e139ca5af"
    static let apiSecret = "4579721b95af2207f0da107393cfdbe1276adb7b17b716dfb7db23afb5295c42"
    static let base = "https://api.trakt.tv"
    static let shows = "/shows"
    static let movies = "/movies"
    static let people = "/people"
    static let person = "/person"
    static let seasons = "/seasons"
    static let episodes = "/episodes"
    static let auth = "/oauth"
    static let token = "/token"
    static let sync = "/sync"
    static let playback = "/playback"
    static let history = "/history"
    static let device = "/device"
    static let code = "/code"
    static let remove = "/remove"
    static let related = "/related"
    static let watched = "/watched"
    static let watchlist = "/watchlist"
    static let scrobble = "/scrobble"
    static let imdb = "/imdb"
    static let tvdb = "/tvdb"
    static let search = "/search"
    
    static let extended = ["extended": "full"]
    public struct Headers {
        static let Default = [
            "Content-Type": "application/json",
            "trakt-api-version": "2",
            "trakt-api-key": Trakt.apiKey
        ]
        
        static func Authorization(_ token: String) -> [String: String] {
            var Authorization = Default; Authorization["Authorization"] = "Bearer \(token)"
            return Authorization
        }
    }
    public enum MediaType: String {
        case movies = "movies"
        case shows = "shows"
        case episodes = "episodes"
        case people = "people"
    }
    /**
     Watched status of media.
     
     - .watching:   When the video intially starts playing or is unpaused.
     - .paused:     When the video is paused.
     - .finished:   When the video is stopped or finishes playing on its own.
     */
    public enum WatchedStatus: String {
        /// When the video intially starts playing or is unpaused.
        case watching = "start"
        /// When the video is paused.
        case paused = "pause"
        /// When the video is stopped or finishes playing on its own.
        case finished = "stop"
    }
}

public struct PopcornShows {
    static let base = NSDictionary(contentsOf: URL(string: "https://raw.githubusercontent.com/getpopcorn/getpopcorn.github.io/master/PopcornAPI.plist")!)?.value(forKey: "popcorn_show_base") as? String ?? "https://tv-v2.api-fetch.sh"
    static let shows = "/shows"
    static let show = "/show"
}

public struct PopcornMovies {
    static let base = NSDictionary(contentsOf: URL(string: "https://raw.githubusercontent.com/getpopcorn/getpopcorn.github.io/master/PopcornAPI.plist")!)?.value(forKey: "popcorn_movie_base") as? String ?? "https://movies-v2.api-fetch.sh"
    static let movies = "/movies"
    static let movie = "/movie"
}

public struct TMDB {
    static let apiKey = "794c6cae006c35f62c1948652dca53fb"
    static let base = "https://api.themoviedb.org/3"
    static let tv = "/tv"
    static let person = "/person"
    static let images = "/images"
    static let season = "/season"
    static let episode = "/episode"
    
    public enum MediaType: String {
        case movies = "movie"
        case shows = "tv"
    }
    
    static let defaultHeaders = ["api_key": TMDB.apiKey]
}

public struct Fanart {
    static let apiKey = "0ff819a1ffd57d3fb004ae4d2fb2678a"
    static let base = "http://webservice.fanart.tv/v3"
    static let tv = "/tv"
    static let movies = "/movies"
    
    static let defaultParameters = ["api_key": Fanart.apiKey]
}

public struct OpenSubtitles {
    static let base = "https://rest.opensubtitles.org/"
    static let userAgent = "Popcorn12"
    
//    static let logIn = "LogIn"
//    static let logOut = "LogOut"
    static let search = "search/"
    
    static let defaultHeaders = ["User-Agent": OpenSubtitles.userAgent]
}

open class NetworkManager: NSObject {
    internal let manager: SessionManager = {
        var configuration = URLSessionConfiguration.default
        configuration.httpCookieAcceptPolicy = .never
        configuration.httpShouldSetCookies = false
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    /// Possible orders used in API call.
    public enum Orders: Int {
        case ascending = 1
        case descending = -1
        
    }
    
    /// Possible genres used in API call.
    public enum Genres: String {
        case all = "All"
        case action = "Action"
        case adventure = "Adventure"
        case animation = "Animation"
        case comedy = "Comedy"
        case crime = "Crime"
        case disaster = "Disaster"
        case documentary = "Documentary"
        case drama = "Drama"
        case family = "Family"
        case fanFilm = "Fan Film"
        case fantasy = "Fantasy"
        case filmNoir = "Film Noir"
        case history = "History"
        case holiday = "Holiday"
        case horror = "Horror"
        case indie = "Indie"
        case music = "Music"
        case mystery = "Mystery"
        case realitytv = "Reality"
        case road = "Road"
        case romance = "Romance"
        case sciFi = "Science Fiction"
        case short = "Short"
        case sports = "Sports"
        case sportingEvent = "Sporting Event"
        case suspense = "Suspense"
        case thriller = "Thriller"
        case war = "War"
        case western = "Western"
        
        public static var array = [all, action, adventure, animation, comedy, crime, disaster, documentary, drama, family, fanFilm, fantasy, filmNoir, history, holiday, horror, indie, music, mystery, realitytv, road, romance, sciFi, short, sports, sportingEvent, suspense, thriller, war, western]
        
        public var string: String {
            return rawValue
        }
    }
}
