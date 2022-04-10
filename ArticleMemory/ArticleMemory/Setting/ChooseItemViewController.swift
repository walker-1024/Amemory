//
//  ChooseItemViewController.swift
//  ArticleMemory
//
//  Created by li on 2021/10/18.
//

import UIKit

class ChooseItem {

    init() { }

    init(_ title: String) {
        self.title = title
    }

    var title: String = ""
    var closure: (() -> Void)? // 此项被用户选中后执行
    var isChosen: Bool = false
}

class ChooseItemViewController: AMUIViewController, UITableViewDelegate, UITableViewDataSource {

    var navTitle: String?
    var items = [ChooseItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = navTitle
        setupTable()
    }

    private func setupTable(){
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "itemCell")
        tableView.backgroundColor = UIColor.backgroundWhite
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints{ (make) -> Void in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        cell.accessoryType = items[indexPath.row].isChosen ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].closure?()
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}
