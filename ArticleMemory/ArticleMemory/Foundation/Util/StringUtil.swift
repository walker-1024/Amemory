//
//  StringUtil.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/3/19.
//

import Foundation
import UIKit

extension String {

    var localized: String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }

    var localImage: UIImage? {
        return UIImage(named: self)
    }

    subscript(i: Int) -> String {
        let begin = self.index(self.startIndex, offsetBy: i)
        return String(self[begin])
    }

    subscript(range: Range<Int>) -> String {
        let begin = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(self.startIndex, offsetBy: range.upperBound)
        return String(self[begin..<end])
    }

    var isNumber: Bool {
        let scanner = Scanner(string: self)
        return scanner.scanFloat() != nil && scanner.isAtEnd
    }

    func regexFind(with pattern: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive) else { return nil }
        let result = regex.matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count))
        var output: [String] = []
        for item in result {
            guard let range = Range(item.range, in: self) else { continue }
            output.append(String(self[range]))
        }
        return output
    }
}
