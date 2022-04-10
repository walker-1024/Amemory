//
//  FileModel.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/4/5.
//

import Foundation

enum FileType: String, Codable {
    case local_pdf = "local_pdf"
    case local_webarchive = "local_webarchive"
    case local_png = "local_png"
    case download_pdf = "download_pdf"
    case download_webarchive = "download_webarchive"
}

struct FileModel: Codable {
    var pdfID: String
    var type: FileType
    var url: URL
    var title: String
    // 若为个人文件，则为保存文件的时间；若为下载文件，则为文章发布日期
    var createTime: String?
    var cover: Data?
    var isDownloading: Bool
}
