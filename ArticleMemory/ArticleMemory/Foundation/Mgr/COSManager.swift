//
//  COSManager.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/5/26.
//

import Foundation
//import QCloudCOSXML

class COSManager: NSObject {

    static let shared = COSManager()

    private var downloadQueue: [DownloadTask] = []
    private var waitQueue: [DownloadTask] = []

    private override init() {
        super.init()
        // some code has been deleted
    }

    func uploadPDF(biz: String, pdfid: String, nsdata: NSData, completion: @escaping () -> Void) {
        // some code has been deleted
    }

    func uploadWA(biz: String, fileId: String, nsdata: NSData, completion: @escaping () -> Void) {
        // some code has been deleted
    }

    func downloadPDF(biz: String, pdfID: String, savePath: String, completion: @escaping () -> Void) {
        // some code has been deleted
    }

    func downloadWA(biz: String, fileId: String, savePath: String, completion: @escaping () -> Void) {
        // some code has been deleted
    }
}

class DownloadTask {

    var biz: String
    var fileType: FileType
    var fileId: String
    var savePath: String
    var completion: (() -> Void)?
    var isCompleted = false

    init(biz: String, fileType: FileType, fileId: String, savePath: String, completion: (() -> Void)? = nil) {
        self.biz = biz
        self.fileType = fileType
        self.fileId = fileId
        self.savePath = savePath
        self.completion = completion
    }

    func startDownload() {
        // some code has been deleted
    }
}
