//
//  Locale+Extension.swift
//  PopcornTime
//
//  Created by Jarrod Norwell on 6/6/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation

extension Locale {
    static var commonISOLanguageCodes: [String] {
        return ["en", "fr", "de", "ja", "nl", "it", "es", "da", "fi", "no", "sv", "ko", "zh", "ru", "pl", "pt", "id", "tr", "hu", "el", "ca","bs","hr","sr", "hi", "th", "ms", "cs", "sk", "vi", "ro", "uk", "ar", "he","sl"].sorted()
    }
    
    static var commonLanguages: [String]  {
        return Locale.commonISOLanguageCodes.compactMap {
            guard let language = Locale.current.localizedString(forLanguageCode: $0) else { return nil }
            return language.localizedCapitalized
        }
    }
}
