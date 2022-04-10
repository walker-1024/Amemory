//
//  ArticleModel.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/6/12.
//

import Foundation

struct ArticleModel: Codable {
    var biz: String
    var pdfID: String
    var title: String
    var url: URL?
    var coverImageURL: URL?
    var publishTime: String
}
