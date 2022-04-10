//
//  ArticleViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/6/12.
//

import UIKit

fileprivate let CellIdentifier = "ArticleTableViewCell"

class ArticleViewController: AMUIViewController {

    var biz: String!

    private var fileData: [ArticleModel] = []

    private var editButton: UIButton!
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setup()
        setupBottomBar()
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if tableView.isEditing {
            self.bottomBar?.isHidden = false
            self.tabBarController?.tabBar.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.bottomBar?.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }

    private func setupNavigationItem() {
        editButton = UIButton()
        editButton.setTitle("多选", for: .normal)
        editButton.setTitle("完成", for: .selected)
        editButton.setTitleColor(.black, for: .normal)
        editButton.addTarget(self, action: #selector(clickEdit(button:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
    }

    private func setup() {

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        tableView = UITableView()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.backgroundColor = UIColor.backgroundWhite
        tableView.separatorStyle = .singleLine
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
    }

    private func setupBottomBar() {
        let favor = BottomBarButton()
        favor.title = "收藏"
        favor.targetAction = #selector(favorSelectedPdfs)
        let selectAll = BottomBarButton()
        selectAll.title = "全选"
        selectAll.targetAction = #selector(selecteAllFile)
        let download = BottomBarButton()
        download.title = "下载"
        download.targetAction = #selector(downloadSelectedFiles(button:))
        self.genBottomBar(buttons: [favor, selectAll, download])
        self.bottomBar?.isHidden = true
    }

    @objc private func refresh() {
        let paras: [String: String] = ["biz": biz]
        let config = WebAPIConfig(subspec: "account", function: "articles")
        NetworkManager.shared.request(config: config, parameters: paras).responseModel { [weak self] (result: NetworkResult<BackDataWrapper<ArticleListBackData>>) in
            guard let self = self else { return }
            switch result {
            case .success(let res):
                guard res.code == 0, let backData = res.data else { break }
                var As: [ArticleModel] = []
                for item in backData.articles {
                    As.append(ArticleModel(
                        biz: item.biz,
                        pdfID: item.pdfID,
                        title: item.title,
                        url: URL(string: item.url),
                        coverImageURL: URL(string: item.cover),
                        publishTime: item.publishTime
                    ))
                }
                DispatchQueue.main.async {
                    self.fileData = As
                    self.tableView.reloadData()
                }
            case .failure(_):
                break
            }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }

    @objc private func clickEdit(button: UIButton) {
        if button.isSelected {
            button.isSelected = false
            self.bottomBar?.isHidden = true
            tableView.setEditing(false, animated: true)
            self.tabBarController?.tabBar.isHidden = false
        } else {
            button.isSelected = true
            self.bottomBar?.isHidden = false
            tableView.setEditing(true, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
    }

    @objc private func favorSelectedPdfs() {
        presentAlert(title: "功能正在开发中", on: self)
    }

    @objc private func selecteAllFile() {
        for i in 0..<fileData.count {
            let indexPath = IndexPath(row: i, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }

    @objc private func downloadSelectedFiles(button: UIButton) {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        var articles: [ArticleModel] = []
        for indexPath in indexPaths {
            articles.append(fileData[indexPath.row])
        }
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let downloadPDFButton = UIAlertAction(title: "下载PDF", style: .default, handler: { _ in
            self.downloadFiles(articles: articles, downloadType: .pdf)
        })
        let downloadWAButton = UIAlertAction(title: "下载WA", style: .default, handler: { _ in
            self.downloadFiles(articles: articles, downloadType: .wa)
        })
        let downloadBothButton = UIAlertAction(title: "下载PDF和WA", style: .default, handler: { _ in
            self.downloadFiles(articles: articles, downloadType: .both)
        })
        let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        vc.addAction(downloadPDFButton)
        vc.addAction(downloadWAButton)
        vc.addAction(downloadBothButton)
        vc.addAction(cancelButton)
        vc.popoverPresentationController?.barButtonItem = UIBarButtonItem(customView: button)
        self.present(vc, animated: true, completion: nil)
    }

    private enum DownloadType {
        case pdf
        case wa
        case both
    }

    private func downloadFiles(articles:[ArticleModel], downloadType: DownloadType) {
        if UserConfigManager.shared.canFreeDownload() {
            switch downloadType {
            case .pdf:
                for article in articles {
                    LocalFileManager.shared.downloadPDFAndSave(article)
                }
            case .wa:
                for article in articles {
                    LocalFileManager.shared.downloadWAAndSave(article)
                }
            case .both:
                for article in articles {
                    LocalFileManager.shared.downloadPDFAndSave(article)
                    LocalFileManager.shared.downloadWAAndSave(article)
                }
            }
            self.endEdit()
            presentAlert(title: "已开始下载", on: self)
            return
        }
        switch downloadType {
        case .pdf:
            let alertC = UIAlertController(title: "下载PDF", message: "将消耗\(articles.count * 10)记忆碎片", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "确定", style: .default, handler: { _ in
                self.requestToDownloadFile(point: articles.count * 10) {
                    for article in articles {
                        LocalFileManager.shared.downloadPDFAndSave(article)
                    }
                    self.endEdit()
                }
            })
            let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertC.addAction(okButton)
            alertC.addAction(cancelButton)
            self.present(alertC, animated: true, completion: nil)
        case .wa:
            let alertC = UIAlertController(title: "下载WA", message: "将消耗\(articles.count * 10)记忆碎片", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "确定", style: .default, handler: { _ in
                self.requestToDownloadFile(point: articles.count * 10) {
                    for article in articles {
                        LocalFileManager.shared.downloadWAAndSave(article)
                    }
                    self.endEdit()
                }
            })
            let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertC.addAction(okButton)
            alertC.addAction(cancelButton)
            self.present(alertC, animated: true, completion: nil)
        case .both:
            let alertC = UIAlertController(title: "下载PDF和WA", message: "将消耗\(articles.count * 15)记忆碎片", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "确定", style: .default, handler: { _ in
                self.requestToDownloadFile(point: articles.count * 15) {
                    for article in articles {
                        LocalFileManager.shared.downloadPDFAndSave(article)
                        LocalFileManager.shared.downloadWAAndSave(article)
                    }
                    self.endEdit()
                }
            })
            let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertC.addAction(okButton)
            alertC.addAction(cancelButton)
            self.present(alertC, animated: true, completion: nil)
        }
    }

    private func requestToDownloadFile(point: Int, successCompletion: (() -> Void)?) {
        // point为需要花费的记忆碎片数量
        let config = WebAPIConfig(subspec: "account", function: "download")
        let paras = DownloadFileParas(point: point)
        NetworkManager.shared.request(config: config, parameters: paras).responseModel { [weak self] (result: NetworkResult<BackDataWrapper<CommonBackData>>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.code == 0 {
                        presentAlert(title: "已开始下载", on: self)
                        successCompletion?()
                    } else {
                        presentAlert(title: "失败", message: res.msg, on: self)
                    }
                case .failure(_):
                    presentAlert(title: "网络请求失败", on: self)
                }
            }
        }
    }

    private func endEdit() {
        editButton.isSelected = false
        self.bottomBar?.isHidden = true
        tableView.setEditing(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
}

extension ArticleViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        if let fileCell = cell as? ArticleTableViewCell {
            fileCell.setupData(fileData[indexPath.row])
            fileCell.showActionSheet = { [weak self] vc in
                guard let self = self else { return }
                if !tableView.isEditing {
                    self.present(vc, animated: true, completion: nil)
                }
            }
            fileCell.showAlert = { [weak self] vc in
                guard let self = self else { return }
                self.present(vc, animated: true, completion: nil)
            }
            fileCell.downloadPDF = { [weak self] in
                guard let self = self else { return }
                self.downloadFiles(articles: [self.fileData[indexPath.row]], downloadType: .pdf)
            }
            fileCell.downloadWA = { [weak self] in
                guard let self = self else { return }
                self.downloadFiles(articles: [self.fileData[indexPath.row]], downloadType: .wa)
            }
            fileCell.downloadPDFAndWA = { [weak self] in
                guard let self = self else { return }
                self.downloadFiles(articles: [self.fileData[indexPath.row]], downloadType: .both)
            }
            fileCell.longPress = { [weak self] in
                guard let self = self else { return }
                if !tableView.isEditing {
                    self.editButton.isSelected = true
                    self.tabBarController?.tabBar.isHidden = true
                    tableView.setEditing(true, animated: true)
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            if let url = fileData[indexPath.row].url {
                let vc = WebpageViewController()
                vc.load(url: url)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
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

fileprivate struct DownloadFileParas: Codable {
    var point: Int
}
