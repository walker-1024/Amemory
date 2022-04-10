//
//  HomeViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/3/16.
//

import UIKit
import SnapKit

class HomeViewController: AMUIViewController {

    private let textField = UITextField()
    private let openButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        LocalFileManager.shared.loadLoadingGifImages()
        LocalFileManager.shared.resumeDownloadFile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        VisitorManager.checkVisitorAccount()
    }

    private func setup() {
        let iconView = UIImageView()
        view.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(110)
            make.width.height.equalTo(120)
        }
        iconView.image = "icon-fit-background".localImage

        let textFieldView = UIImageView()
        view.addSubview(textFieldView)
        textFieldView.isUserInteractionEnabled = true
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        textFieldView.snp.makeConstraints { make in
            make.width.equalTo(310)
            make.height.equalTo(62)
            make.top.equalTo(iconView.snp.bottom).offset(80)
            make.centerX.equalToSuperview()
        }
        textFieldView.image = "icon-innershadow-textfield".localImage
        textFieldView.contentMode = .scaleToFill

        textFieldView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.snp.makeConstraints { make in
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.height.equalTo(45)
            make.centerY.equalToSuperview()
        }
        textField.backgroundColor = UIColor.clear
        textField.text = ""
        textField.attributedPlaceholder = NSAttributedString(string: "请输入网页链接", attributes: [.foregroundColor: UIColor.textFieldPlaceholderFontColor])
        textField.textColor = UIColor.textFieldTextColor
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
        textField.leftViewMode = .always
        textField.delegate = self

        let buttonView = UIImageView()
        view.addSubview(buttonView)
        buttonView.isUserInteractionEnabled = true
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.snp.makeConstraints { make in
            make.width.equalTo(110)
            make.height.equalTo(70)
            make.top.equalTo(textFieldView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        buttonView.image = "icon-shadow-button".localImage
        buttonView.contentMode = .scaleToFill

        buttonView.addSubview(openButton)
        openButton.translatesAutoresizingMaskIntoConstraints = false
        openButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(35)
            make.centerY.equalToSuperview()
        }
        openButton.backgroundColor = .clear
        openButton.setTitle("打开网页", for: .normal)
        openButton.setTitleColor(UIColor.homeShadowButtonTitleColorDisable, for: .disabled)
        openButton.setTitleColor(UIColor.homeShadowButtonTitleColor, for: .normal)
        openButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        openButton.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        openButton.isEnabled = false
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }

    @objc private func clickButton() {
        // 不加 addingPercentEncoding 会导致含有中文字符的string转为URL时候失败
        guard let str = textField.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = URL(string: str) else { return }
        let vc = WebpageViewController()
        vc.load(url: url)
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 不推迟的话，在恰好删完所有文字的情况下是 enable，不符合预期
        DispatchQueue.main.async {
            self.openButton.isEnabled = textField.text?.count != 0 || string.count != 0
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        openButton.isEnabled = false
        return true
    }
}
