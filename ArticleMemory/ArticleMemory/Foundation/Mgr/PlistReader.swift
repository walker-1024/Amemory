//
//  PlistReader.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/3/16.
//

import Foundation

class PlistReader {

    private init() { }

    static let shared = PlistReader()

    func getDict(from fileName: String) -> NSDictionary? {

        guard let file = Bundle.main.path(forResource: fileName, ofType: "plist") else {
            return nil
        }

        guard let fileData = NSDictionary(contentsOfFile: file) else {
            return nil
        }

        return fileData
    }
}
