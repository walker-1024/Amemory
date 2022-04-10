//
//  OfficialAccountModel.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/6/11.
//

import Foundation

struct OfficialAccountModel: Codable {
    var biz: String
    var name: String
    var coverImageURL: URL?
    var articleCount: Int
}
