//
//  LocalFileManager.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/6/2.
//

import Foundation
import UIKit
import CoreData

class LocalFileManager {

    static let shared = LocalFileManager()

    private let documentsPath = NSHomeDirectory() + "/Documents/"
    private let localPdfPath = NSHomeDirectory() + "/Documents/local/pdf/"
    private let localWAPath = NSHomeDirectory() + "/Documents/local/archive/"
    private let localPngPath = NSHomeDirectory() + "/Documents/local/png/"
    private let downloadPdfPath = NSHomeDirectory() + "/Documents/download/pdf/"
    private let downloadWAPath = NSHomeDirectory() + "/Documents/download/archive/"
    private let avatarPath = NSHomeDirectory() + "/Documents/avatar.png"
    private let coverPath = NSHomeDirectory() + "/tmp/cover/"
    private let shareFilePath = NSHomeDirectory() + "/tmp/shareFile/"
    private let fileManager = FileManager()

    var loadingGifImages: [UIImage]?

    private init() {
        do {
            try fileManager.createDirectory(atPath: localPdfPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: localWAPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: localPngPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: downloadPdfPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: downloadWAPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: coverPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: shareFilePath, withIntermediateDirectories: true, attributes: nil)
        } catch {
        }
    }

    func getFilePath(pdfID: String, fileType: String) -> String {
        if fileType == FileType.local_pdf.rawValue {
            return localPdfPath + pdfID + ".pdf"
        } else if fileType == FileType.local_webarchive.rawValue {
            return localWAPath + pdfID + ".webarchive"
        } else if fileType == FileType.local_png.rawValue {
            return localPngPath + pdfID + ".png"
        } else if fileType == FileType.download_pdf.rawValue {
            return downloadPdfPath + pdfID + ".pdf"
        } else if fileType == FileType.download_webarchive.rawValue {
            return downloadWAPath + pdfID + ".webarchive"
        } else {
            return ""
        }
    }

    func getLocalFiles() -> [FileModel]? {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return nil
        }

        var files: [FileModel] = []
        do {
            let fetchRequest = NSFetchRequest<PdfEntity>(entityName:"PdfEntity")
            let res = try context.fetch(fetchRequest)
            for item in res {
                guard let url = URL(string: item.url ?? "") else { continue }
                guard let type = FileType(rawValue: item.type ?? "") else { continue }
                guard type == .local_pdf || type == .local_webarchive || type == .local_png else { continue }
                guard let pdfID = item.pdfID else { continue }
                let pdf = FileModel(
                    pdfID: pdfID,
                    type: type,
                    url: url,
                    title: item.title ?? "",
                    createTime: item.createTime,
                    cover: item.cover,
                    isDownloading: item.isDownloading
                )
                guard fileManager.fileExists(atPath: getFilePath(pdfID: pdfID, fileType: type.rawValue)) else { continue }
                files.append(pdf)
            }
        } catch {
            return nil
        }

        return files
    }

    func getDownloadFiles() -> [FileModel]? {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return nil
        }

        var files: [FileModel] = []
        do {
            let fetchRequest = NSFetchRequest<PdfEntity>(entityName:"PdfEntity")
            let res = try context.fetch(fetchRequest)
            for item in res {
                guard let url = URL(string: item.url ?? "") else { continue }
                guard let type = FileType(rawValue: item.type ?? "") else { continue }
                guard type == .download_pdf || type == .download_webarchive else { continue }
                guard let pdfID = item.pdfID else { continue }
                let pdf = FileModel(
                    pdfID: pdfID,
                    type: type,
                    url: url,
                    title: item.title ?? "",
                    createTime: item.createTime,
                    cover: item.cover,
                    isDownloading: item.isDownloading
                )
                files.append(pdf)
            }
        } catch {
            return nil
        }

        return files
    }

    func saveLocalFile(data: Data, type: FileType, title: String, url: String) -> Bool {
        let hash = data.md5
        var path: String!
        if type == .local_pdf {
            path = localPdfPath + hash + ".pdf"
        } else if type == .local_webarchive {
            path = localWAPath + hash + ".webarchive"
        } else {
            path = localPngPath + hash + ".png"
        }

        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return false
        }
        guard let item = NSEntityDescription.insertNewObject(forEntityName: "PdfEntity", into: context) as? PdfEntity else {
            return false
        }

        guard fileManager.createFile(atPath: path, contents: data, attributes: nil) else {
            return false
        }

        item.pdfID = hash
        item.type = type.rawValue
        item.title = title
        item.url = url
        item.createTime = Date().formatString
        item.isDownloading = false
        do {
            try context.save()
        } catch {
            try? fileManager.removeItem(atPath: path)
            return false
        }
        return true
    }

    func downloadPDFAndSave(_ article: ArticleModel) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        guard let item = NSEntityDescription.insertNewObject(forEntityName: "PdfEntity", into: context) as? PdfEntity else {
            return
        }
        let fileType = FileType.download_pdf.rawValue

        item.pdfID = article.pdfID
        item.type = fileType
        item.title = article.title
        item.url = article.url?.absoluteString
        item.createTime = article.publishTime
        item.isDownloading = true
        try? context.save()

        let path = downloadPdfPath + article.pdfID + ".pdf"
        COSManager.shared.downloadPDF(biz: article.biz, pdfID: article.pdfID, savePath: path) {
            var cover: Data? = nil
            if let url = article.coverImageURL {
                cover = try? Data(contentsOf: url)
            }
            DispatchQueue.main.async {
                self.onFileDownloadSuccess(fileId: article.pdfID, fileType: fileType, cover: cover)
                let userInfo: [String : Any] = [
                    "fileId": article.pdfID,
                    "fileType": FileType.download_pdf,
                    "cover": cover as Any
                ]
                NotificationCenter.default.post(name: .downloadSuccess, object: self, userInfo: userInfo)
            }
        }
    }

    func downloadWAAndSave(_ article: ArticleModel) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        guard let item = NSEntityDescription.insertNewObject(forEntityName: "PdfEntity", into: context) as? PdfEntity else {
            return
        }
        let fileType = FileType.download_webarchive.rawValue

        item.pdfID = article.pdfID
        item.type = fileType
        item.title = article.title
        item.url = article.url?.absoluteString
        item.createTime = article.publishTime
        item.isDownloading = true
        try? context.save()

        let path = downloadWAPath + article.pdfID + ".webarchive"
        COSManager.shared.downloadWA(biz: article.biz, fileId: article.pdfID, savePath: path) {
            var cover: Data? = nil
            if let url = article.coverImageURL {
                cover = try? Data(contentsOf: url)
            }
            DispatchQueue.main.async {
                self.onFileDownloadSuccess(fileId: article.pdfID, fileType: fileType, cover: cover)
                let userInfo: [String : Any] = [
                    "fileId": article.pdfID,
                    "fileType": FileType.download_webarchive,
                    "cover": cover as Any
                ]
                NotificationCenter.default.post(name: .downloadSuccess, object: self, userInfo: userInfo)
            }
        }
    }

    func onFileDownloadSuccess(fileId: String, fileType: String, cover: Data?) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        let fetchRequest = NSFetchRequest<PdfEntity>(entityName:"PdfEntity")
        let predicate = NSPredicate(format: "pdfID == \"\(fileId)\" && type == \"\(fileType)\"")
        fetchRequest.predicate = predicate
        do {
            let res = try context.fetch(fetchRequest)
            guard res.count > 0 else { return }
            res[0].cover = cover
            res[0].isDownloading = false
            try context.save()
        }
        catch {
        }
    }

    // 私人文件和下载文件通用
    func renameFile(file: FileModel, newTitle: String) -> Bool {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return false
        }
        let fetchRequest = NSFetchRequest<PdfEntity>(entityName:"PdfEntity")
        let predicate = NSPredicate(format: "pdfID == \"\(file.pdfID)\" && type == \"\(file.type.rawValue)\"")
        fetchRequest.predicate = predicate
        do {
            let res = try context.fetch(fetchRequest)
            guard res.count > 0 else { return false }
            res[0].title = newTitle
            try context.save()
        }
        catch {
            return false
        }
        return true
    }

    // 私人文件和下载文件通用
    func deleteFile(file: FileModel) -> Bool {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return false
        }
        let fetchRequest = NSFetchRequest<PdfEntity>(entityName:"PdfEntity")
        let predicate = NSPredicate(format: "pdfID == \"\(file.pdfID)\" && type == \"\(file.type.rawValue)\"")
        fetchRequest.predicate = predicate
        do {
            let res = try context.fetch(fetchRequest)
            guard res.count > 0 else { return false }
            guard let type = res[0].type else { return false }
            context.delete(res[0])
            try context.save()
            try fileManager.removeItem(atPath: getFilePath(pdfID: file.pdfID, fileType: type))
        } catch {
            return false
        }
        return true
    }

    // 私人文件和下载文件通用
    func deleteSomeFiles(files: [FileModel]) -> Bool {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return false
        }
        var flag = true
        let fetchRequest = NSFetchRequest<PdfEntity>(entityName:"PdfEntity")
        for file in files {
            fetchRequest.predicate = NSPredicate(format: "pdfID == \"\(file.pdfID)\" && type == \"\(file.type.rawValue)\"")
            do {
                let res = try context.fetch(fetchRequest)
                guard res.count > 0 else {
                    flag = false
                    continue
                }
                guard let type = res[0].type else {
                    flag = false
                    continue
                }
                context.delete(res[0])
                try fileManager.removeItem(atPath: getFilePath(pdfID: file.pdfID, fileType: type))
            } catch {
                flag = false
                continue
            }
        }
        do {
            try context.save()
        } catch {
            flag = false
        }
        return flag
    }

    // 分享时copy为一份新的文件，以网页标题命名
    func getShareFileUrls(files: [FileModel]) -> [URL] {
        var urls: [URL] = []
        for file in files {
            let oldPath = getFilePath(pdfID: file.pdfID, fileType: file.type.rawValue)
            let suffix = String(oldPath.split(separator: ".").last ?? "")
            let newPath = shareFilePath + "\(file.title.count > 0 ? file.title : file.pdfID).\(suffix)"
            try? fileManager.removeItem(atPath: newPath)
            try? fileManager.copyItem(atPath: oldPath, toPath: newPath)
            urls.append(URL(fileURLWithPath: newPath))
        }
        return urls
    }

    func saveCover(data: Data, name: String) {
        let path = coverPath + name + ".pic"
        fileManager.createFile(atPath: path, contents: data, attributes: nil)
    }

    func getCover(name: String) -> Data? {
        let path = coverPath + name + ".pic"
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        return data
    }

    func saveAvatar(data: Data) {
        fileManager.createFile(atPath: avatarPath, contents: data, attributes: nil)
    }

    func getAvatar() -> Data? {
        let data = try? Data(contentsOf: URL(fileURLWithPath: avatarPath))
        return data
    }

    func isNeedUpdateAvatar(md5: String) -> Bool {
        if md5.count == 0 { return false }
        let data = try? Data(contentsOf: URL(fileURLWithPath: avatarPath))
        if data?.md5 == md5 { return false }
        return true
    }

    func clearCache() {
        // 删除封面图片
        let files = try? fileManager.contentsOfDirectory(atPath: coverPath)
        for file in files ?? [] {
            try? fileManager.removeItem(atPath: coverPath + file)
        }
        // 删除分享的临时文件
        let files2 = try? fileManager.contentsOfDirectory(atPath: shareFilePath)
        for file in files2 ?? [] {
            try? fileManager.removeItem(atPath: shareFilePath + file)
        }
        // 删除 tmp 中的非目录文件
        let tmpPath = NSHomeDirectory() + "/tmp/"
        let files3 = try? fileManager.contentsOfDirectory(atPath: tmpPath)
        for file in files3 ?? [] {
            if file.contains(".") {
                try? fileManager.removeItem(atPath: tmpPath + file)
            }
        }

        // 删除野文件
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        guard var localPdfFiles = try? fileManager.contentsOfDirectory(atPath: localPdfPath) else { return }
        guard var localWAFiles = try? fileManager.contentsOfDirectory(atPath: localWAPath) else { return }
        guard var localPngFiles = try? fileManager.contentsOfDirectory(atPath: localPngPath) else { return }
        guard var downloadPdfFiles = try? fileManager.contentsOfDirectory(atPath: downloadPdfPath) else { return }
        guard var downloadWAFiles = try? fileManager.contentsOfDirectory(atPath: downloadWAPath) else { return }
        do {
            let fetchRequest = NSFetchRequest<PdfEntity>(entityName:"PdfEntity")
            let res = try context.fetch(fetchRequest)
            for item in res {
                guard let pdfID = item.pdfID else { continue }
                guard let type = FileType(rawValue: item.type ?? "") else { continue }
                if type == .local_pdf {
                    if let index = localPdfFiles.firstIndex(of: pdfID) {
                        localPdfFiles.remove(at: index)
                    }
                } else if type == .local_webarchive {
                    if let index = localWAFiles.firstIndex(of: pdfID) {
                        localWAFiles.remove(at: index)
                    }
                } else if type == .local_png {
                    if let index = localPngFiles.firstIndex(of: pdfID) {
                        localPngFiles.remove(at: index)
                    }
                } else if type == .download_pdf {
                    if let index = downloadPdfFiles.firstIndex(of: pdfID) {
                        downloadPdfFiles.remove(at: index)
                    }
                } else if type == .download_webarchive {
                    if let index = downloadWAFiles.firstIndex(of: pdfID) {
                        downloadWAFiles.remove(at: index)
                    }
                }
            }
        } catch {
            return
        }
        for pdfID in localPdfFiles {
            try? fileManager.removeItem(atPath: localPdfPath + pdfID + ".pdf")
        }
        for pdfID in localWAFiles {
            try? fileManager.removeItem(atPath: localWAPath + pdfID + ".webarchive")
        }
        for pdfID in localPngFiles {
            try? fileManager.removeItem(atPath: localPngPath + pdfID + ".png")
        }
        for pdfID in downloadPdfFiles {
            try? fileManager.removeItem(atPath: downloadPdfPath + pdfID + ".pdf")
        }
        for pdfID in downloadWAFiles {
            try? fileManager.removeItem(atPath: downloadWAPath + pdfID + ".webarchive")
        }
    }

    // 暂时先写在这里吧
    func loadLoadingGifImages() {
        if loadingGifImages != nil { return }
        guard let gifPath = Bundle.main.path(forResource: "loading", ofType: "gif") else {
            return
        }
        guard let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)) else {
            return
        }
        guard let gifDataSource = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            return
        }
        let gifImageCount = CGImageSourceGetCount(gifDataSource)
        if gifImageCount == 0 { return }
        var images: [UIImage] = []
        for i in 0..<gifImageCount {
            guard let imageRef: CGImage = CGImageSourceCreateImageAtIndex(gifDataSource, i, nil) else {
                continue
            }
            let image = UIImage(cgImage: imageRef)
            images.append(image)
         }
        self.loadingGifImages = images
    }

    // 若存在被杀进程等操作中断的下载任务，则启动APP后重新开始下载
    func resumeDownloadFile() {
        guard var files = self.getDownloadFiles() else { return }
        guard let _ = UserConfigManager.shared.getValue(of: .token) else { return }
        files.removeAll { model in
            return !model.isDownloading
        }
        if files.count == 0 { return }
        let pdfids = files.compactMap { model in
            return model.pdfID
        }
        let config = WebAPIConfig(subspec: "account", function: "articleDetail")
        let paras = ArticleDetailPara(articles: pdfids)
        NetworkManager.shared.request(config: config, parameters: paras).responseModel { [weak self] (result: NetworkResult<BackDataWrapper<ArticleListBackData>>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    guard res.code == 0, let backData = res.data else { break }
                    for file in files {
                        if file.type == .download_pdf {
                            guard let article = backData.articles.first(where: { model in
                                return model.pdfID == file.pdfID
                            }) else { continue }
                            let path = self.downloadPdfPath + article.pdfID + ".pdf"
                            COSManager.shared.downloadPDF(biz: article.biz, pdfID: article.pdfID, savePath: path) {
                                var cover: Data? = nil
                                if let url = URL(string: article.cover) {
                                    cover = try? Data(contentsOf: url)
                                }
                                DispatchQueue.main.async {
                                    self.onFileDownloadSuccess(fileId: article.pdfID, fileType: file.type.rawValue, cover: cover)
                                    let userInfo: [String : Any] = [
                                        "fileId": article.pdfID,
                                        "fileType": FileType.download_pdf,
                                        "cover": cover as Any
                                    ]
                                    NotificationCenter.default.post(name: .downloadSuccess, object: self, userInfo: userInfo)
                                }
                            }
                        } else if file.type == .download_webarchive {
                            guard let article = backData.articles.first(where: { model in
                                return model.pdfID == file.pdfID
                            }) else { continue }
                            let path = self.downloadWAPath + article.pdfID + ".webarchive"
                            COSManager.shared.downloadWA(biz: article.biz, fileId: article.pdfID, savePath: path) {
                                var cover: Data? = nil
                                if let url = URL(string: article.cover) {
                                    cover = try? Data(contentsOf: url)
                                }
                                DispatchQueue.main.async {
                                    self.onFileDownloadSuccess(fileId: article.pdfID, fileType: file.type.rawValue, cover: cover)
                                    let userInfo: [String : Any] = [
                                        "fileId": article.pdfID,
                                        "fileType": FileType.download_webarchive,
                                        "cover": cover as Any
                                    ]
                                    NotificationCenter.default.post(name: .downloadSuccess, object: self, userInfo: userInfo)
                                }
                            }
                        }
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
}

fileprivate struct ArticleDetailPara: Codable {
    var articles: [String]
}

fileprivate struct ArticleListBackData: Codable {
    struct Article: Codable {
        var biz: String
        var pdfID: String
        var title: String
        var url: String
        var cover: String
        var publishTime: String
    }
    var articles: [Article]
}

fileprivate struct ResetAvatarBackData: Codable {
    var avatarHash: String
}
