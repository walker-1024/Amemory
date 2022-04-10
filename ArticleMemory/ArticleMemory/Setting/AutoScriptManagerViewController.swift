//
//  AutoScriptManagerViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/10/12.
//

import UIKit

fileprivate let ScriptCellIdentifier = "ScriptTableViewCell"

class AutoScriptManagerViewController: AMUIViewController {

    private var scriptData: [ScriptModel] = []

    private var editButton: UIButton!
    private var scriptTableView: UITableView!
    private var refreshControl: UIRefreshControl!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "脚本管理"
        setupNavigationItem()
        setup()
        setupBottomBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if scriptTableView.isEditing {
            self.bottomBar?.isHidden = false
        }
        scriptData = ScriptManager.shared.getScripts()
        scriptTableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.bottomBar?.isHidden = true
    }

    private func setupNavigationItem() {
        editButton = UIButton()
        editButton.setTitle("管理", for: .normal)
        editButton.setTitle("完成", for: .selected)
        editButton.setTitleColor(.black, for: .normal)
        editButton.addTarget(self, action: #selector(clickEdit(button:)), for: .touchUpInside)

        let addButton = UIButton()
        addButton.setTitle("添加", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.addTarget(self, action: #selector(clickAdd), for: .touchUpInside)
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: addButton),
            UIBarButtonItem(customView: editButton)
        ]
    }

    private func setup() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        scriptTableView = UITableView()
        view.addSubview(scriptTableView)
        scriptTableView.translatesAutoresizingMaskIntoConstraints = false
        scriptTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scriptTableView.backgroundColor = UIColor.backgroundWhite
        scriptTableView.separatorStyle = .singleLine
        scriptTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scriptTableView.allowsMultipleSelectionDuringEditing = true
        scriptTableView.register(ScriptTableViewCell.self, forCellReuseIdentifier: ScriptCellIdentifier)
        scriptTableView.delegate = self
        scriptTableView.dataSource = self
        scriptTableView.refreshControl = refreshControl
        scriptTableView.tableFooterView = UIView()
    }

    private func setupBottomBar() {
        let selectAll = BottomBarButton()
        selectAll.title = "全选"
        selectAll.targetAction = #selector(selectAllFile)

        let delete = BottomBarButton()
        delete.title = "删除"
        delete.targetAction = #selector(deleteSelectFile)

        self.genBottomBar(buttons: [selectAll, delete])

        self.bottomBar?.isHidden = true
    }

    private func showScriptDescription(script: ScriptModel) {
        let vc = ScriptDescriptionViewController()
        vc.setScriptModel(script: script)
        self.present(vc, animated: false, completion: nil)
    }

    @objc private func clickAdd() {
        let vc = EditScriptViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickEdit(button: UIButton) {
        if button.isSelected {
            button.isSelected = false
            scriptTableView.setEditing(false, animated: true)
            self.bottomBar?.isHidden = true
        } else {
            button.isSelected = true
            scriptTableView.setEditing(true, animated: true)
            self.bottomBar?.isHidden = false
        }
    }

    @objc private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.scriptData = ScriptManager.shared.getScripts()
            self.scriptTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    @objc private func selectAllFile() {
        for i in 0..<scriptData.count {
            let indexPath = IndexPath(row: i, section: 0)
            scriptTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }

    @objc private func deleteSelectFile() {
        guard var indexPaths = scriptTableView.indexPathsForSelectedRows else { return }
        let alert = UIAlertController(title: "删除所选脚本", message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "删除", style: .destructive, handler: { _ in
            // 按 row 倒序排序
            indexPaths.sort(by: { return $0.row > $1.row })
            var deleteScriptIds: [String] = []
            for item in indexPaths {
                deleteScriptIds.append(self.scriptData[item.row].scriptId)
                self.scriptData.remove(at: item.row)
            }
            self.scriptTableView.deleteRows(at: indexPaths, with: .fade)
            self.scriptTableView.reloadData()
            self.editButton.isSelected = false
            self.scriptTableView.setEditing(false, animated: true)
            self.bottomBar?.isHidden = true
            ScriptManager.shared.delete(scriptIds: deleteScriptIds)
        })
        let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
}

extension AutoScriptManagerViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scriptData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScriptCellIdentifier, for: indexPath)
        if let scriptCell = cell as? ScriptTableViewCell {
            scriptCell.setupData(scriptData[indexPath.row])
            scriptCell.changeSwitchValue = { [weak self] isOn in
                guard let self = self else { return }
                ScriptManager.shared.setScript(script: self.scriptData[indexPath.row], isEnable: isOn)
            }
            scriptCell.editScript = { [weak self] in
                guard let self = self else { return }
                let vc = EditScriptViewController()
                vc.script = self.scriptData[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
            scriptCell.longPress = { [weak self] in
                guard let self = self else { return }
                if !tableView.isEditing {
                    self.editButton.isSelected = true
                    self.bottomBar?.isHidden = false
                    tableView.setEditing(true, animated: true)
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            self.showScriptDescription(script: self.scriptData[indexPath.row])
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}
