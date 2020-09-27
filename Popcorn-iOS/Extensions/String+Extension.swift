

import Foundation
import UIKit.NSAttributedString

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
    
    func slice(from start: String, to: String) -> String? {
        return (range(of: start)?.upperBound).flatMap { sInd in
            let eInd = range(of: to, range: sInd..<endIndex)
            if eInd != nil {
                return (eInd?.lowerBound).map { eInd in
                    return "\(self[sInd..<eInd])"
                }
            }
            return "\(self[sInd..<endIndex])"
        }
    }
    
    var slugged: String {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-")
        
        var cocoaString = String(self)
        cocoaString = cocoaString.applyingTransform(.toLatin, reverse: false) ?? ""
        cocoaString = cocoaString.applyingTransform(.stripCombiningMarks, reverse: false) ?? ""
        cocoaString = cocoaString.lowercased()
        
        return String(cocoaString)
            .components(separatedBy: allowedCharacters.inverted)
            .filter { $0 != "" }
            .joined(separator: "-")
    }
    
    static func random(of length: Int) -> String {
        let alphabet = "-_1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map { _ -> Character in
            return alphabet[alphabet.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(UInt32(alphabet.count))))]
        })
    }
    
    var queryString: [String: String] {
        var queryStringDictionary = [String: String]()
        let urlComponents = components(separatedBy: "&")
        for keyValuePair in urlComponents {
            let pairComponents = keyValuePair.components(separatedBy: "=")
            let key = pairComponents.first?.removingPercentEncoding
            let value = pairComponents.last?.removingPercentEncoding
            queryStringDictionary[key!] = value!
        }
        return queryStringDictionary
    }
    
    func trimWhiteSpace() -> String {
        let string = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return string
    }
}
