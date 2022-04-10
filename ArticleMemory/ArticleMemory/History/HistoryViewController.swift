//
//  HistoryViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/5/10.
//

import UIKit

class HistoryViewController: AMUIViewController {

    var privateFileButton: UIButton!
    var downloadFileButton: UIButton!
    var editButton: UIButton!
    var searchButton: UIButton!
    var searchBar: UISearchBar!

    private var privateFileTableView: UITableView!
    private var privateFileTableViewDelegate: FileTableViewDelegate!
    private var downloadFileTableView: UITableView!
    private var downloadFileTableViewDelegate: FileTableViewDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopbar()
        setupPrivateFileTableView()
        setupDownloadFileTableView()
        downloadFileTableView.isHidden = true
        downloadFileTableView.transform = CGAffineTransform(translationX: ScreenWidth, y: 0)
        setupBottomBar()
        NotificationCenter.default.addObserver(self, selector: #selector(onDownloadSuccess(notification:)), name: .downloadSuccess, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if let files = LocalFileManager.shared.getLocalFiles() {
            privateFileTableViewDelegate.fileData = files
            privateFileTableView.reloadData()
        }
        if let files = LocalFileManager.shared.getDownloadFiles() {
            downloadFileTableViewDelegate.fileData = files
            downloadFileTableView.reloadData()
        }
        VisitorManager.checkVisitorAccount()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupTopbar() {
        let topbar = UIView()
        view.addSubview(topbar)
        topbar.translatesAutoresizingMaskIntoConstraints = false
        topbar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(StatusBarH)
            make.height.equalTo(NavBarH)
        }

        privateFileButton = UIButton()
        topbar.addSubview(privateFileButton)
        privateFileButton.translatesAutoresizingMaskIntoConstraints = false
        privateFileButton.snp.makeConstraints { make in
            make.leading.equalTo(10)
            make.width.equalTo(90)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        privateFileButton.setTitle("个人文件", for: .normal)
        privateFileButton.setTitleColor(.black, for: .selected)
        privateFileButton.setTitleColor(.gray, for: .normal)
        privateFileButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        privateFileButton.isSelected = true
        privateFileButton.tag = 1
        privateFileButton.addTarget(self, action: #selector(selectFilePage(button:)), for: .touchUpInside)

        downloadFileButton = UIButton()
        topbar.addSubview(downloadFileButton)
        downloadFileButton.translatesAutoresizingMaskIntoConstraints = false
        downloadFileButton.snp.makeConstraints { make in
            make.leading.equalTo(privateFileButton.snp.trailing).offset(10)
            make.width.equalTo(privateFileButton)
            make.height.equalTo(privateFileButton)
            make.centerY.equalToSuperview()
        }
        downloadFileButton.setTitle("下载文件", for: .normal)
        downloadFileButton.setTitleColor(.black, for: .selected)
        downloadFileButton.setTitleColor(.gray, for: .normal)
        downloadFileButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        downloadFileButton.tag = 2
        downloadFileButton.addTarget(self, action: #selector(selectFilePage(button:)), for: .touchUpInside)

        editButton = UIButton()
        topbar.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.snp.makeConstraints { make in
            make.trailing.equalTo(-10)
            make.width.equalTo(50)
            make.height.equalTo(privateFileButton)
            make.centerY.equalToSuperview()
        }
        editButton.setTitle("编辑", for: .normal)
        editButton.setTitle("完成", for: .selected)
        editButton.setTitleColor(.black, for: .normal)
        editButton.addTarget(self, action: #selector(clickEdit(button:)), for: .touchUpInside)

        searchButton = UIButton()
        topbar.addSubview(searchButton)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.snp.makeConstraints { make in
            make.trailing.equalTo(editButton.snp.leading).offset(-5)
            make.width.equalTo(editButton)
            make.height.equalTo(editButton)
            make.centerY.equalToSuperview()
        }
        searchButton.setTitle("搜索", for: .normal)
        searchButton.setTitleColor(.black, for: .normal)
        searchButton.addTarget(self, action: #selector(clickSearch), for: .touchUpInside)

        searchBar = UISearchBar()
        topbar.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundColor = UIColor.backgroundWhite
        searchBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        searchBar.placeholder = "搜索"
        searchBar.showsCancelButton = true
        searchBar.keyboardType = .default
        searchBar.returnKeyType = .done
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        searchBar.isHidden = true
    }

    private func setupPrivateFileTableView() {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshControl.tag = 1
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged)

        privateFileTableView = UITableView()
        privateFileTableViewDelegate = FileTableViewDelegate(fileType: .PrivateFile)
        view.addSubview(privateFileTableView)
        privateFileTableView.translatesAutoresizingMaskIntoConstraints = false
        privateFileTableView.snp.makeConstraints { make in
            make.top.equalTo(StatusBarH + NavBarH)
            make.leading.trailing.bottom.equalToSuperview()
        }
        privateFileTableView.backgroundColor = UIColor.backgroundWhite
        privateFileTableView.separatorStyle = .singleLine
        privateFileTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        privateFileTableView.allowsMultipleSelectionDuringEditing = true
        privateFileTableView.register(FileTableViewCell.self, forCellReuseIdentifier: privateFileTableViewDelegate.identifier)
        privateFileTableView.delegate = privateFileTableViewDelegate
        privateFileTableView.dataSource = privateFileTableViewDelegate
        privateFileTableView.refreshControl = refreshControl
        privateFileTableView.tableFooterView = UIView()

        privateFileTableViewDelegate.openFile = { [weak self] file in
            guard let self = self else { return }
            let vc = FilepageViewController()
            vc.fileModel = file
            self.navigationController?.pushViewController(vc, animated: true)
        }
        privateFileTableViewDelegate.openOriginalWebpage = { [weak self] url in
            guard let self = self else { return }
            let vc = WebpageViewController()
            vc.load(url: url)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        privateFileTableViewDelegate.presentVC = { [weak self] vc in
            guard let self = self else { return }
            self.present(vc, animated: true, completion: nil)
        }
        privateFileTableViewDelegate.beginEdit = { [weak self] in
            guard let self = self else { return }
            self.editButton.isSelected = true
            self.tabBarController?.tabBar.isHidden = true
            if !self.privateFileButton.isSelected {
                self.privateFileButton.isEnabled = false
            }
            if !self.downloadFileButton.isSelected {
                self.downloadFileButton.isEnabled = false
            }
            self.searchButton.isEnabled = false
        }
        privateFileTableViewDelegate.endEdit = { [weak self] in
            guard let self = self else { return }
            self.editButton.isSelected = false
            self.tabBarController?.tabBar.isHidden = false
            self.privateFileButton.isEnabled = true
            self.downloadFileButton.isEnabled = true
            self.searchButton.isEnabled = true
            self.bottomBar?.isHidden = true
        }
    }

    private func setupDownloadFileTableView() {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshControl.tag = 2
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged)

        downloadFileTableView = UITableView()
        downloadFileTableViewDelegate = FileTableViewDelegate(fileType: .DownloadFile)
        view.addSubview(downloadFileTableView)
        downloadFileTableView.translatesAutoresizingMaskIntoConstraints = false
        downloadFileTableView.snp.makeConstraints { make in
            make.top.equalTo(StatusBarH + NavBarH)
            make.leading.trailing.bottom.equalToSuperview()
        }
        downloadFileTableView.backgroundColor = UIColor.backgroundWhite
        downloadFileTableView.separatorStyle = .singleLine
        downloadFileTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        downloadFileTableView.allowsMultipleSelectionDuringEditing = true
        downloadFileTableView.register(FileTableViewCell.self, forCellReuseIdentifier: downloadFileTableViewDelegate.identifier)
        downloadFileTableView.delegate = downloadFileTableViewDelegate
        downloadFileTableView.dataSource = downloadFileTableViewDelegate
        downloadFileTableView.refreshControl = refreshControl
        downloadFileTableView.tableFooterView = UIView()

        downloadFileTableViewDelegate.openFile = { [weak self] file in
            guard let self = self else { return }
            let vc = FilepageViewController()
            vc.fileModel = file
            self.navigationController?.pushViewController(vc, animated: true)
        }
        downloadFileTableViewDelegate.openOriginalWebpage = { [weak self] url in
            guard let self = self else { return }
            let vc = WebpageViewController()
            vc.load(url: url)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        downloadFileTableViewDelegate.presentVC = { [weak self] vc in
            guard let self = self else { return }
            self.present(vc, animated: true, completion: nil)
        }
        downloadFileTableViewDelegate.beginEdit = { [weak self] in
            guard let self = self else { return }
            self.editButton.isSelected = true
            self.tabBarController?.tabBar.isHidden = true
        }
        downloadFileTableViewDelegate.endEdit = {  [weak self] in
            guard let self = self else { return }
            self.editButton.isSelected = false
            self.tabBarController?.tabBar.isHidden = false
            self.privateFileButton.isEnabled = true
            self.downloadFileButton.isEnabled = true
            self.searchButton.isEnabled = true
            self.bottomBar?.isHidden = true
        }
    }

    private func setupBottomBar() {
        let favor = BottomBarButton()
        favor.title = "收藏"
        favor.targetAction = #selector(favorSelectedPdfs)
        let share = BottomBarButton()
        share.title = "分享"
        share.targetAction = #selector(shareSelectedFiles(button:))
        let selectAll = BottomBarButton()
        selectAll.title = "全选"
        selectAll.targetAction = #selector(selecteAllFile)
        let delete = BottomBarButton()
        delete.title = "删除"
        delete.targetAction = #selector(deleteSelectedFiles)
        self.genBottomBar(buttons: [favor, share, selectAll, delete])
        self.bottomBar?.isHidden = true
    }

    @objc private func selectFilePage(button: UIButton) {
        if button.tag == 1 {
            if !privateFileButton.isSelected {
                privateFileButton.isSelected = true
                downloadFileButton.isSelected = false
                self.privateFileTableView.isHidden = false
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.privateFileTableView.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.downloadFileTableView.transform = CGAffineTransform(translationX: ScreenWidth, y: 0)
                }, completion: { _ in
                    if !self.downloadFileButton.isSelected {
                        self.downloadFileTableView.isHidden = true
                    }
                })
            }
        } else {
            if privateFileButton.isSelected {
                privateFileButton.isSelected = false
                downloadFileButton.isSelected = true
                self.downloadFileTableView.isHidden = false
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.privateFileTableView.transform = CGAffineTransform(translationX: -ScreenWidth, y: 0)
                    self.downloadFileTableView.transform = CGAffineTransform(translationX: 0, y: 0)
                }, completion: { _ in
                    if !self.privateFileButton.isSelected {
                        self.privateFileTableView.isHidden = true
                    }
                })
            }
        }
    }

    @objc private func refresh(refreshControl: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            if refreshControl.tag == 1 {
                if let files = LocalFileManager.shared.getLocalFiles() {
                    privateFileTableViewDelegate.fileData = files
                    privateFileTableView.reloadData()
                }
            } else {
                if let files = LocalFileManager.shared.getDownloadFiles() {
                    downloadFileTableViewDelegate.fileData = files
                    downloadFileTableView.reloadData()
                }
            }
            refreshControl.endRefreshing()
        }
    }

    @objc private func clickEdit(button: UIButton) {
        if editButton.isSelected {
            privateFileButton.isEnabled = true
            downloadFileButton.isEnabled = true
            searchButton.isEnabled = true
            self.bottomBar?.isHidden = true
        } else {
            if !privateFileButton.isSelected {
                privateFileButton.isEnabled = false
            }
            if !downloadFileButton.isSelected {
                downloadFileButton.isEnabled = false
            }
            searchButton.isEnabled = false
            self.bottomBar?.isHidden = false
        }
        if privateFileButton.isSelected {
            if privateFileTableView.isEditing {
                button.isSelected = false
                privateFileTableView.setEditing(false, animated: true)
                self.tabBarController?.tabBar.isHidden = false
            } else {
                button.isSelected = true
                privateFileTableView.setEditing(true, animated: true)
                self.tabBarController?.tabBar.isHidden = true
            }
        } else {
            if downloadFileTableView.isEditing {
                button.isSelected = false
                downloadFileTableView.setEditing(false, animated: true)
                self.tabBarController?.tabBar.isHidden = false
            } else {
                button.isSelected = true
                downloadFileTableView.setEditing(true, animated: true)
                self.tabBarController?.tabBar.isHidden = true
            }
        }
    }

    @objc private func clickSearch() {
//        searchBar.isHidden = false
//        searchBar.becomeFirstResponder()
        presentAlert(title: "功能正在开发中", on: self)
    }

    @objc private func favorSelectedPdfs() {
        presentAlert(title: "功能正在开发中", on: self)
    }

    @objc private func shareSelectedFiles(button: UIButton) {
        if privateFileButton.isSelected {
            privateFileTableViewDelegate.shareSelectedFiles(privateFileTableView, button: button)
        } else {
            downloadFileTableViewDelegate.shareSelectedFiles(downloadFileTableView, button: button)
        }
    }

    @objc private func selecteAllFile() {
        if privateFileButton.isSelected {
            for i in 0..<privateFileTableViewDelegate.fileData.count {
                let indexPath = IndexPath(row: i, section: 0)
                privateFileTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        } else {
            for i in 0..<downloadFileTableViewDelegate.fileData.count {
                let indexPath = IndexPath(row: i, section: 0)
                downloadFileTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }

    @objc private func deleteSelectedFiles() {
        if privateFileButton.isSelected {
            privateFileTableViewDelegate.deleteSelectedFiles(privateFileTableView)
        } else {
            downloadFileTableViewDelegate.deleteSelectedFiles(downloadFileTableView)
        }
    }

    @objc private func onDownloadSuccess(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let fileId = userInfo["fileId"] as? String else { return }
        guard let fileType = userInfo["fileType"] as? FileType else { return }
        let cover = userInfo["cover"] as? Data
        let index = downloadFileTableViewDelegate.fileData.firstIndex { model in
            return model.pdfID == fileId && model.type == fileType
        }
        guard let theIndex = index else { return }
        downloadFileTableViewDelegate.fileData[theIndex].isDownloading = false
        downloadFileTableViewDelegate.fileData[theIndex].cover = cover
        if let cell = downloadFileTableView.cellForRow(at: IndexPath(row: theIndex, section: 0)) as? FileTableViewCell {
            cell.setupData(downloadFileTableViewDelegate.fileData[theIndex])
        }
    }
}

extension HistoryViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }

}
