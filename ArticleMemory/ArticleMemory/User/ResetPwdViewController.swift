//
//  ResetPwdViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/7/24.
//

import UIKit

class ResetPwdViewController: AMUIViewController {

    private var emailField: UITextField!
    private var pwdField: UITextField!
    private var codeField: UITextField!
    private var resetPwdButton: UIButton!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupBackButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        guard let email = UserConfigManager.shared.getValue(of: .email) else { return }
        emailField.text = email
    }

    private func setup() {
        let iconView = UIImageView()
        view.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
            make.top.equalTo(100)
        }
        iconView.image = "icon-fit-background".localImage

        // 邮箱输入栏
        let emailView = UIImageView()
        view.addSubview(emailView)
        emailView.isUserInteractionEnabled = true
        emailView.translatesAutoresizingMaskIntoConstraints = false
        emailView.snp.makeConstraints { make in
            make.width.equalTo(340)
            make.height.equalTo(80)
            make.top.equalTo(iconView.snp.bottom).offset(70)
            make.centerX.equalToSuperview()
        }
        emailView.image = "icon-shadow-textfield".localImage
        emailView.contentMode = .scaleToFill

        emailField = UITextField()
        emailView.addSubview(emailField)
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.snp.makeConstraints { make in
            make.leading.equalTo(35)
            make.trailing.equalTo(-35)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        emailField.backgroundColor = UIColor.clear
        emailField.text = ""
        emailField.attributedPlaceholder = NSAttributedString(string: "请输入邮箱", attributes: [.foregroundColor: UIColor.textFieldPlaceholderFontColor])
        emailField.textAlignment = .center
        emailField.font = UIFont.systemFont(ofSize: 18)
        emailField.textColor = UIColor.textFieldTextColor
        emailField.keyboardType = .default
        emailField.returnKeyType = .done
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        emailField.delegate = self

        // 密码输入栏
        let pwdView = UIImageView()
        view.addSubview(pwdView)
        pwdView.isUserInteractionEnabled = true
        pwdView.translatesAutoresizingMaskIntoConstraints = false
        pwdView.snp.makeConstraints { make in
            make.width.equalTo(340)
            make.height.equalTo(80)
            make.top.equalTo(emailView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        pwdView.image = "icon-shadow-textfield".localImage
        pwdView.contentMode = .scaleToFill

        pwdField = UITextField()
        pwdView.addSubview(pwdField)
        pwdField.translatesAutoresizingMaskIntoConstraints = false
        pwdField.snp.makeConstraints { make in
            make.leading.equalTo(35)
            make.trailing.equalTo(-35)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        pwdField.backgroundColor = UIColor.clear
        pwdField.text = ""
        pwdField.attributedPlaceholder = NSAttributedString(string: "请输入新密码", attributes: [.foregroundColor: UIColor.textFieldPlaceholderFontColor])
        pwdField.textAlignment = .center
        pwdField.font = UIFont.systemFont(ofSize: 18)
        pwdField.textColor = UIColor.textFieldTextColor
        pwdField.keyboardType = .default
        pwdField.returnKeyType = .done
        pwdField.autocorrectionType = .no
        pwdField.autocapitalizationType = .none
        pwdField.isSecureTextEntry = true
        pwdField.delegate = self

        // 验证码输入栏
        let codeView = UIImageView()
        view.addSubview(codeView)
        codeView.isUserInteractionEnabled = true
        codeView.translatesAutoresizingMaskIntoConstraints = false
        codeView.snp.makeConstraints { make in
            make.width.equalTo(340)
            make.height.equalTo(80)
            make.top.equalTo(pwdView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        codeView.image = "icon-shadow-textfield".localImage
        codeView.contentMode = .scaleToFill

        let codeButton = UIButton()
        codeView.addSubview(codeButton)
        codeButton.translatesAutoresizingMaskIntoConstraints = false
        codeButton.snp.makeConstraints { make in
            make.trailing.equalTo(-30)
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        codeButton.setTitle("获取验证码", for: .normal)
        codeButton.setTitleColor(UIColor.thirdLabelColor, for: .normal)
        codeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        codeButton.addTarget(self, action: #selector(clickSendCode(button:)), for: .touchUpInside)

        codeField = UITextField()
        codeView.addSubview(codeField)
        codeField.translatesAutoresizingMaskIntoConstraints = false
        codeField.snp.makeConstraints { make in
            make.leading.equalTo(35)
            make.trailing.equalTo(codeButton.snp.leading).offset(-5)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        codeField.backgroundColor = UIColor.clear
        codeField.text = ""
        codeField.attributedPlaceholder = NSAttributedString(string: "请输入验证码", attributes: [.foregroundColor: UIColor.textFieldPlaceholderFontColor])
        codeField.textAlignment = .left
        codeField.font = UIFont.systemFont(ofSize: 18)
        codeField.textColor = UIColor.textFieldTextColor
        codeField.keyboardType = .default
        codeField.returnKeyType = .done
        codeField.autocorrectionType = .no
        codeField.autocapitalizationType = .none
        codeField.delegate = self

        resetPwdButton = UIButton()
        view.addSubview(resetPwdButton)
        resetPwdButton.translatesAutoresizingMaskIntoConstraints = false
        resetPwdButton.snp.makeConstraints { make in
            make.width.equalTo(150)
            // 图片宽332 高308
            make.height.equalTo(150 * 308 / 332)
            make.top.equalTo(pwdView.snp.bottom).offset(80)
            make.centerX.equalToSuperview()
        }
        resetPwdButton.setImage("icon-login-check".localImage, for: .normal)
        resetPwdButton.adjustsImageWhenHighlighted = false
        resetPwdButton.addTarget(self, action: #selector(clickResetPwd(button:)), for: .touchUpInside)
    }

    private func setupBackButton() {
        let backButton = UIButton()
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.width.height.equalTo(35)
            make.top.equalTo(60)
        }
        backButton.setImage("icon-back".localImage?.resizeImage(size: CGSize(width: 28, height: 28)), for: .normal)
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
    }

    @objc private func clickBack() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func clickSendCode(button: UIButton) {
        guard let email = emailField.text else { return }
        button.isEnabled = false
        let paras = ["email": email]
        let config = WebAPIConfig(subspec: "user", function: "send_code")
        NetworkManager.shared.request(config: config, parameters: paras).responseModel { [weak self] (result: NetworkResult<BackDataWrapper<CommonBackData>>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.code == 0 {
                        button.setTitle("验证码已发送", for: .normal)
                    } else {
                        presentAlert(title: "验证码发送失败", message: res.msg, on: self)
                    }
                case .failure(_):
                    presentAlert(title: "网络请求失败", on: self)
                }
                button.isEnabled = true
            }
        }
    }

    @objc private func clickResetPwd(button: UIButton) {
        guard let email = emailField.text, let password = pwdField.text, let code = codeField.text else { return }
        if email.count == 0 || password.count == 0 || code.count == 0 {
            presentAlert(title: "请填写完整信息", on: self)
            return
        }
        button.isEnabled = false
        let paras = ["email": email, "password": password, "verificationCode": code]
        let config = WebAPIConfig(subspec: "user", function: "resetPassword")
        NetworkManager.shared.request(config: config, parameters: paras).responseModel { [weak self] (result: NetworkResult<BackDataWrapper<CommonBackData>>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.code == 0 {
                        // 只有在没有登录时找回密码的情况下，才需要记录下邮箱和密码用于免除在Login页的登录
                        if UserConfigManager.shared.getBoolValue(of: .visitor) {
                            UserConfigManager.shared.saveValue(email, to: .email)
                            UserConfigManager.shared.saveValue(password, to: .password)
                        }
                        let alert = UIAlertController(title: "重置密码成功", message: nil, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "确定", style: .default) { _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        presentAlert(title: "重置密码失败", message: res.msg, on: self)
                    }
                case .failure(_):
                    presentAlert(title: "网络请求失败", on: self)
                }
                button.isEnabled = true
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        emailField.resignFirstResponder()
        pwdField.resignFirstResponder()
        codeField.resignFirstResponder()
    }

}

extension ResetPwdViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
