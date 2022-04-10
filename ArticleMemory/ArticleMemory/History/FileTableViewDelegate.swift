//
//  FileTableViewDelegate.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/4/5.
//

import UIKit

class FileTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {

    enum FileType: String {
        case PrivateFile = "FileTableViewCell_PrivateFile"
        case DownloadFile = "FileTableViewCell_DownloadFile"
    }

    var fileType: FileType
    var identifier: String

    var fileData: [FileModel] = []

    var openFile: ((FileModel) -> Void)?
    var openOriginalWebpage: ((URL) -> Void)?
    var presentVC: ((UIViewController) -> Void)?
    var beginEdit: (() -> Void)?
    var endEdit: (() -> Void)?

    init(fileType: FileType) {
        self.fileType = fileType
        self.identifier = fileType.rawValue
        super.init()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let fileCell = cell as? FileTableViewCell {
            fileCell.setupData(fileData[indexPath.row])
            fileCell.openOriginalWebpage = { [weak self] in
                guard let self = self else { return }
                self.openOriginalWebpage?(self.fileData[indexPath.row].url)
            }
            fileCell.showActionSheet = { [weak self] vc in
                guard let self = self else { return }
                if !tableView.isEditing {
                    self.presentVC?(vc)
                }
            }
            fileCell.showAlert = { [weak self] vc in
                guard let self = self else { return }
                self.presentVC?(vc)
            }
            fileCell.shareFile = { [weak self] in
                guard let self = self else { return }
                if self.fileData[indexPath.row].isDownloading {
                    let alert = UIAlertController(title: "文件正在下载中", message: nil, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.presentVC?(alert)
                    return
                }
                let fileUrls = LocalFileManager.shared.getShareFileUrls(files: [self.fileData[indexPath.row]])
                let activityVC = UIActivityViewController(activityItems: fileUrls, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = fileCell
                self.presentVC?(activityVC)
            }
            fileCell.renameFile = { [weak self] newTitle in
                guard let self = self else { return }
                guard LocalFileManager.shared.renameFile(file: self.fileData[indexPath.row], newTitle: newTitle) else {
                    return
                }
                self.fileData[indexPath.row].title = newTitle
                tableView.reloadData()
            }
            fileCell.deleteFile = { [weak self] in
                guard let self = self else { return }
                guard LocalFileManager.shared.deleteFile(file: self.fileData[indexPath.row]) else {
                    return
                }
                self.fileData.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
            }
            fileCell.longPress = { [weak self] in
                guard let self = self else { return }
                if !tableView.isEditing {
                    self.beginEdit?()
                    tableView.setEditing(true, animated: true)
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            if fileData[indexPath.row].isDownloading {
                let alert = UIAlertController(title: "文件正在下载中", message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
                alert.addAction(ok)
                self.presentVC?(alert)
            } else {
                openFile?(fileData[indexPath.row])
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func shareSelectedFiles(_ tableView: UITableView, button: UIButton) {
        guard var indexPaths = tableView.indexPathsForSelectedRows else { return }
        // 按 row 正序排序
        indexPaths.sort(by: { return $0.row < $1.row })
        var files: [FileModel] = []
        var isDownloading = false
        for indexPath in indexPaths {
            let file = self.fileData[indexPath.row]
            if file.isDownloading {
                isDownloading = true
                break
            }
            files.append(file)
        }
        if isDownloading {
            let alert = UIAlertController(title: "分享失败", message: "部分文件正在下载中", preferredStyle: .alert)
            let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(ok)
            self.presentVC?(alert)
            return
        }
        let fileUrls = LocalFileManager.shared.getShareFileUrls(files: files)
        let activityVC = UIActivityViewController(activityItems: fileUrls, applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = UIBarButtonItem(customView: button)
        self.presentVC?(activityVC)
    }

    func deleteSelectedFiles(_ tableView: UITableView) {
        guard var indexPaths = tableView.indexPathsForSelectedRows else { return }

        let alert = UIAlertController(title: "删除文件", message: "删除后将无法恢复", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "删除", style: .destructive, handler: { _ in
            // 按 row 倒序排序
            indexPaths.sort(by: { return $0.row > $1.row })
            var pdfs: [FileModel] = []
            for item in indexPaths {
                pdfs.append(self.fileData[item.row])
                self.fileData.remove(at: item.row)
            }
            tableView.deleteRows(at: indexPaths, with: .fade)
            tableView.reloadData()
            tableView.setEditing(false, animated: true)
            self.endEdit?()
            let r = LocalFileManager.shared.deleteSomeFiles(files: pdfs)
            if !r {
                let alert = UIAlertController(title: "出现错误", message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
                alert.addAction(ok)
                self.presentVC?(alert)
            }
        })
        let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        presentVC?(alert)
    }
}
