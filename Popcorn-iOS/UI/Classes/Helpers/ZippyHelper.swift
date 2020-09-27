//
//  ZippyHelper.swift
//  Popcorn-iOS
//
//  Created by Antique on 21/7/20.
//  Copyright © 2020 Jarrod Norwell. All rights reserved.
//

import Foundation

class ZippyHelper : NSObject {
    class func gunzip(path: URL, language: String, completion: @escaping (String) -> Void) {
        let folderPath = (path.absoluteString as NSString).deletingLastPathComponent
        (folderPath as NSString).replacingOccurrences(of: "file:", with: "")
        
        if FileManager.default.fileExists(atPath: "\(folderPath)/\(language).srt") {
            do {
                try FileManager.default.removeItem(atPath: "\(folderPath)/\(language).srt")
            } catch {
                print(error.localizedDescription)
            }
        }
        
        do {
            let uncompressed = try Data(contentsOf: URL(string: path.absoluteString)!).gunzipped()
            do {
                try uncompressed.write(to: URL(string: "\(folderPath)/\(language).srt")!)
                completion("\(folderPath)/\(language).srt")
                
                do {
                    try FileManager.default.removeItem(at: URL(string: path.absoluteString)!)
                } catch {
                    print(error.localizedDescription)
                }
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
