//
//  OfficialAccountViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/6/1.
//

import UIKit

fileprivate let CellIdentifier = "OfficialAccountTableViewCell"

class OfficialAccountViewController: AMUIViewController {

    var fileData: [OfficialAccountModel] = []

    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        VisitorManager.checkVisitorAccount()
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
        tableView.register(OfficialAccountTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl

        let footerView = UILabel()
        footerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 90)
        footerView.text = "2022年4月1日00:00起，将停止更新部分公众号的文章。已存在的文章开放自由下载，且将在一个暂未知的时间关闭。"
        footerView.textColor = .secondaryLabelColor
        footerView.textAlignment = .center
        footerView.numberOfLines = 0
        tableView.tableFooterView = footerView
    }

    @objc private func refresh() {
        let config = WebAPIConfig(subspec: "account", function: "accounts")
        NetworkManager.shared.request(config: config).responseModel { [weak self] (result: NetworkResult<BackDataWrapper<AccountsListBackData>>) in
            guard let self = self else { return }
            switch result {
            case .success(let res):
                guard res.code == 0, let backData = res.data else { break }
                var OAs: [OfficialAccountModel] = []
                for item in backData.accounts {
                    OAs.append(OfficialAccountModel(
                        biz: item.biz,
                        name: item.name,
                        coverImageURL: URL(string: item.cover),
                        articleCount: item.count
                    ))
                }
                DispatchQueue.main.async {
                    self.fileData = OAs
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
}

extension OfficialAccountViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        if let fileCell = cell as? OfficialAccountTableViewCell {
            fileCell.setupData(fileData[indexPath.row])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ArticleViewController()
        vc.biz = fileData[indexPath.row].biz
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

fileprivate struct AccountsListBackData: Codable {
    struct Account: Codable {
        var biz: String
        var name: String
        var cover: String
        var count: Int
    }
    var accounts: [Account]
}
