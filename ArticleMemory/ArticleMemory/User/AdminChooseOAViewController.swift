//
//  AddArticleViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/7/31.
//

import UIKit

class AdminChooseOAViewController: AMUIViewController {

    var data: [OfficialAccountModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIButton()
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.width.height.equalTo(28)
            make.top.equalTo(100)
        }
        backButton.setImage("icon-back".localImage, for: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func getData() {
        let config = WebAPIConfig(subspec: "account", function: "accounts")
        NetworkManager.shared.request(config: config).responseModel { (result: NetworkRequest.Result<AccountsListBackData>) in
            switch result {
            case .success(let res):
                var OAs: [OfficialAccountModel] = []
                for item in res.accounts {
                    OAs.append(OfficialAccountModel(
                        biz: item.biz,
                        name: item.name,
                        coverImageURL: URL(string: item.cover),
                        articleCount: item.count
                    ))
                }
                self.data = OAs
            case .failure(_):
                presentAlert(title: "网络请求错误", on: self)
            }
        }
    }

    private func setupView() {
        var i = 0
        while i < data.count {
            let button = UIButton()
            view.addSubview(button)
            button.frame = CGRect(x: 30, y: CGFloat(70 + i * 30), width: 160, height: 30)
            button.setTitle(data[i].name, for: .normal)
            button.setTitleColor(UIColor.labelColor, for: .normal)
            button.tag = i
            button.addTarget(self, action: #selector(clickOA), for: .touchUpInside)
            i += 1
            let button2 = UIButton()
            view.addSubview(button2)
            button2.frame = CGRect(x: 200, y: CGFloat(70 + i * 30), width: 160, height: 30)
            button2.setTitle(data[i].name, for: .normal)
            button2.tag = i
            button2.setTitleColor(UIColor.labelColor, for: .normal)
            i += 1
        }
    }

    @objc private func clickOA(button: UIButton) {
        let vc = AdminAddArticleViewController()
        vc.biz = data[button.tag].biz
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func back() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AdminChooseOAViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    var code: Int
    var msg: String
}
