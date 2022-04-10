//
//  SettingViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/7/27.
//

import UIKit

fileprivate let SettingCellIdentifier = "SettingCellIdentifier"

fileprivate class SettingItem {

    enum SettingCellType {
        case switchButton
        case disclosureIndicator
    }

    init() { }

    init(_ title: String) {
        self.title = title
    }

    var title: String = ""
    var subTitle: String?
    var cellType: SettingCellType = .disclosureIndicator
    var isSwitchButtonOn: Bool = false
    var swtichButtonTag: Int = 0
    var closure: (() -> Void)?
}

private enum SwitchButtonTag: Int {
    case WebVCNavBarBlur = 100
}

class SettingViewController: AMUIViewController {

    private var settingItems: [[SettingItem]] = []

    private let parallelDownloadNumButton = ShadowButtonView()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "设置"
        setupSettingItem()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setupSettingItem() {
        let item1 = SettingItem("PDF分页策略")
        item1.closure = { [weak self] in
            guard let self = self else { return }
            let vc = PdfPageSplitSettingViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let item2 = SettingItem("网页导航栏毛玻璃效果")
        item2.subTitle = "开启时生成的PDF上方将存在一定高度空白"
        item2.cellType = .switchButton
        item2.isSwitchButtonOn = UserConfigManager.shared.getBoolValue(of: .webVCNavBarBlur)
        item2.swtichButtonTag = SwitchButtonTag.WebVCNavBarBlur.rawValue
        let item3 = SettingItem("脚本管理")
        item3.closure = { [weak self] in
            guard let self = self else { return }
            let vc = AutoScriptManagerViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let item4 = SettingItem("同时下载文件数")
        item4.closure = { [weak self] in
            guard let self = self else { return }
            let five = ChooseItem("5")
            five.closure = {
                UserConfigManager.shared.saveValue(5, to: .parallelDownloadNum)
            }
            let ten = ChooseItem("10")
            ten.closure = {
                UserConfigManager.shared.saveValue(10, to: .parallelDownloadNum)
            }
            let fifteen = ChooseItem("15")
            fifteen.closure = {
                UserConfigManager.shared.saveValue(15, to: .parallelDownloadNum)
            }
            let tewnty = ChooseItem("20")
            tewnty.closure = {
                UserConfigManager.shared.saveValue(20, to: .parallelDownloadNum)
            }

            let num = UserConfigManager.shared.getIntValue(of: .parallelDownloadNum)
            let items = [five, ten, fifteen, tewnty]
            for item in items {
                item.isChosen = item.title == String(num)
            }

            let vc = ChooseItemViewController()
            vc.navTitle = "同时下载文件数"
            vc.items = items
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let item5 = SettingItem("清除缓存")
        item5.closure = { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: "清除缓存", message: "不会删除个人文件和下载文件", preferredStyle: .alert)
            let ok = UIAlertAction(title: "确定", style: .default, handler: { _ in
                LocalFileManager.shared.clearCache()
            })
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        let item6 = SettingItem("联系我们")
        item6.closure = { [weak self] in
            guard let self = self else { return }
            let vc = WebpageViewController()
            vc.isSaveButtonHidden = true
            vc.load(str: StaticWebpageUrlContactUs)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let item7 = SettingItem("关于")
        item7.closure = { [weak self] in
            guard let self = self else { return }
            let vc = AboutViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        settingItems = [
            [item1],
            [item2],
            [item3, item4, item5],
            [item6, item7]
        ]
    }

    private func setup() {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        view.addSubview(tableView)
        tableView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        tableView.backgroundColor = UIColor.backgroundWhite
        tableView.separatorStyle = .singleLine
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }

    @objc private func switchValueChanged(switchButton: UISwitch) {
        switch switchButton.tag {
        case SwitchButtonTag.WebVCNavBarBlur.rawValue:
            UserConfigManager.shared.saveValue(switchButton.isOn, to: .webVCNavBarBlur)
        default:
            break
        }
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return settingItems.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if let c = tableView.dequeueReusableCell(withIdentifier: SettingCellIdentifier) {
            cell = c
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: SettingCellIdentifier)
        }
        cell.textLabel?.text = settingItems[indexPath.section][indexPath.row].title
        cell.detailTextLabel?.text = settingItems[indexPath.section][indexPath.row].subTitle
        switch settingItems[indexPath.section][indexPath.row].cellType {
        case .switchButton:
            let btn = UISwitch()
            btn.isOn = settingItems[indexPath.section][indexPath.row].isSwitchButtonOn
            btn.tag = settingItems[indexPath.section][indexPath.row].swtichButtonTag
            btn.addTarget(self, action: #selector(switchValueChanged(switchButton:)), for: .valueChanged)
            cell.accessoryView = btn
        case .disclosureIndicator:
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingItems[indexPath.section][indexPath.row].closure?()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return settingItems[indexPath.section][indexPath.row].subTitle != nil ? 60 : 50
    }
}
