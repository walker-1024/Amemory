//
//  PdfPageSplitSettingViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/12/9.
//

import UIKit

fileprivate let PdfPageSplitSettingCellIdentifier = "PdfPageSplitSettingCellIdentifier"

class PdfPageSplitSettingViewController: AMUIViewController {

    var settingItems: [ChooseItem] = []

    private let customView = UIView()
    private let widthTextField = UITextField()
    private let heightTextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PDF分页策略"
        setupSettingItem()
        setup()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        widthTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
    }

    private func setupSettingItem() {
        let none = ChooseItem("不分页")
        none.closure = { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.customView.alpha = 0
            }, completion: nil)
            UserConfigManager.shared.saveValue(-1, to: .pdfPageSplit)
        }
//        let auto = ChooseItem("自动分页")
//        auto.closure = { [weak self] in
//            guard let self = self else { return }
//            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
//                self.customView.alpha = 0
//            }, completion: nil)
//            UserConfigManager.shared.saveValue(-2, to: .pdfPageSplit)
//        }
        let customRatio = ChooseItem("按比例分页")
        customRatio.closure = { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.customView.alpha = 1
            }, completion: nil)
            UserConfigManager.shared.saveValue(-4, to: .pdfPageSplit)
        }

        switch UserConfigManager.shared.getIntValue(of: .pdfPageSplit) {
        case -1:
            none.isChosen = true
        case -4:
            customRatio.isChosen = true
        default:
            break
        }

        settingItems = [none, customRatio]
    }

    private func setup(){
        let tableView = UITableView()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        tableView.backgroundColor = UIColor.backgroundWhite
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PdfPageSplitSettingCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = customView

        customView.frame = CGRect(x: 0, y: 0, width: 0, height: 250)
        customView.backgroundColor = .white
        customView.alpha = UserConfigManager.shared.getIntValue(of: .pdfPageSplit) > -3 ? 0 : 1

        let tipLabel = UILabel()
        customView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.height.equalTo(45)
            make.centerX.equalToSuperview()
        }
        tipLabel.text = "横向长度   :   纵向长度"

        customView.addSubview(widthTextField)
        widthTextField.snp.makeConstraints { make in
            make.top.equalTo(tipLabel.snp.bottom).offset(10)
            make.height.equalTo(45)
            make.width.equalTo(120)
            make.trailing.equalTo(customView.snp.centerX).offset(-10)
        }
        widthTextField.text = "\(UserConfigManager.shared.getFloatValue(of: .pdfPageSplitWidth))"
        widthTextField.textAlignment = .center
        widthTextField.textColor = UIColor.settingVCTextFieldTextColor
        widthTextField.keyboardType = .default
        widthTextField.returnKeyType = .done
        widthTextField.autocorrectionType = .no
        widthTextField.autocapitalizationType = .none
        widthTextField.delegate = self
        widthTextField.layer.borderWidth = 1
        widthTextField.layer.borderColor = UIColor.settingVCTextFieldBorderColor.cgColor
        widthTextField.layer.cornerRadius = 5
        widthTextField.layer.masksToBounds = true

        customView.addSubview(heightTextField)
        heightTextField.snp.makeConstraints { make in
            make.top.equalTo(widthTextField)
            make.height.width.equalTo(widthTextField)
            make.leading.equalTo(customView.snp.centerX).offset(10)
        }
        heightTextField.text = "\(UserConfigManager.shared.getFloatValue(of: .pdfPageSplitHeight))"
        heightTextField.textAlignment = .center
        heightTextField.textColor = UIColor.settingVCTextFieldTextColor
        heightTextField.keyboardType = .default
        heightTextField.returnKeyType = .done
        heightTextField.autocorrectionType = .no
        heightTextField.autocapitalizationType = .none
        heightTextField.delegate = self
        heightTextField.layer.borderWidth = 1
        heightTextField.layer.borderColor = UIColor.settingVCTextFieldBorderColor.cgColor
        heightTextField.layer.cornerRadius = 5
        heightTextField.layer.masksToBounds = true

        let paperRatioButton = UIButton()
        customView.addSubview(paperRatioButton)
        paperRatioButton.snp.makeConstraints { make in
            make.top.equalTo(widthTextField.snp.bottom).offset(30)
            make.height.equalTo(45)
            make.centerX.equalToSuperview()
        }
        paperRatioButton.setTitle("选择常见纸张比例", for: .normal)
        paperRatioButton.setTitleColor(.blue, for: .normal)
        let A3 = UIAction(title: "A3（297 × 420）", state: .off) { action in
            self.widthTextField.text = "297"
            self.heightTextField.text = "420"
            UserConfigManager.shared.saveValue(297, to: .pdfPageSplitWidth)
            UserConfigManager.shared.saveValue(420, to: .pdfPageSplitHeight)
        }
        let A4 = UIAction(title: "A4（210 × 297）", state: .off) { action in
            self.widthTextField.text = "210"
            self.heightTextField.text = "297"
            UserConfigManager.shared.saveValue(210, to: .pdfPageSplitWidth)
            UserConfigManager.shared.saveValue(297, to: .pdfPageSplitHeight)
        }
        let A5 = UIAction(title: "A5（148 × 210）", state: .off) { action in
            self.widthTextField.text = "148"
            self.heightTextField.text = "210"
            UserConfigManager.shared.saveValue(148, to: .pdfPageSplitWidth)
            UserConfigManager.shared.saveValue(210, to: .pdfPageSplitHeight)
        }
        let A6 = UIAction(title: "A6（105 × 148）", state: .off) { action in
            self.widthTextField.text = "105"
            self.heightTextField.text = "148"
            UserConfigManager.shared.saveValue(105, to: .pdfPageSplitWidth)
            UserConfigManager.shared.saveValue(148, to: .pdfPageSplitHeight)
        }
        let B4 = UIAction(title: "B4（250 × 353）", state: .off) { action in
            self.widthTextField.text = "250"
            self.heightTextField.text = "353"
            UserConfigManager.shared.saveValue(250, to: .pdfPageSplitWidth)
            UserConfigManager.shared.saveValue(353, to: .pdfPageSplitHeight)
        }
        let B5 = UIAction(title: "B5（176 × 250）", state: .off) { action in
            self.widthTextField.text = "176"
            self.heightTextField.text = "250"
            UserConfigManager.shared.saveValue(176, to: .pdfPageSplitWidth)
            UserConfigManager.shared.saveValue(250, to: .pdfPageSplitHeight)
        }
        let B6 = UIAction(title: "B6（125 × 176）", state: .off) { action in
            self.widthTextField.text = "125"
            self.heightTextField.text = "176"
            UserConfigManager.shared.saveValue(125, to: .pdfPageSplitWidth)
            UserConfigManager.shared.saveValue(176, to: .pdfPageSplitHeight)
        }
        paperRatioButton.menu = UIMenu(title: "选择常见纸张比例", children: [A3, A4, A5, A6, B4, B5, B6])
        paperRatioButton.showsMenuAsPrimaryAction = true
    }
}

extension PdfPageSplitSettingViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PdfPageSplitSettingCellIdentifier, for: indexPath)
        cell.textLabel?.text = settingItems[indexPath.row].title
        cell.accessoryType = settingItems[indexPath.row].isChosen ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingItems[indexPath.row].closure?()
        settingItems.forEach { item in
            item.isChosen = false
        }
        settingItems[indexPath.row].isChosen = true
        tableView.visibleCells.forEach { cell in
            cell.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension PdfPageSplitSettingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.count == 0 || string.isNumber
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let width = Float(widthTextField.text ?? "") else { return }
        guard let height = Float(heightTextField.text ?? "") else { return }
        UserConfigManager.shared.saveValue(width, to: .pdfPageSplitWidth)
        UserConfigManager.shared.saveValue(height, to: .pdfPageSplitHeight)
    }
}
