//
//  LoginViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/7/4.
//

import UIKit

class LoginViewController: AMUIViewController {

    private var emailField: UITextField!
    private var pwdField: UITextField!
    private var loginButton: UIButton!

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
        guard let password = UserConfigManager.shared.getValue(of: .password) else { return }
        UserConfigManager.shared.removeValue(of: .password)
        let paras = ["email": email, "password": password]
        let config = WebAPIConfig(subspec: "user", function: "login")
        NetworkManager.shared.request(config: config, parameters: paras).responseModel { [weak self] (result: NetworkResult<BackDataWrapper<LoginBackData>>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.code == 0, let backData = res.data {
                        UserConfigManager.shared.saveValue(backData.token, to: .token)
                        UserConfigManager.shared.removeValue(of: .visitor)
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(_):
                    break
                }
            }
        }
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
        pwdField.attributedPlaceholder = NSAttributedString(string: "请输入密码", attributes: [.foregroundColor: UIColor.textFieldPlaceholderFontColor])
        pwdField.textAlignment = .center
        pwdField.font = UIFont.systemFont(ofSize: 18)
        pwdField.textColor = UIColor.textFieldTextColor
        pwdField.keyboardType = .default
        pwdField.returnKeyType = .done
        pwdField.autocorrectionType = .no
        pwdField.autocapitalizationType = .none
        pwdField.isSecureTextEntry = true
        pwdField.delegate = self

        let findPwdTipLabel = UILabel()
        view.addSubview(findPwdTipLabel)
        findPwdTipLabel.translatesAutoresizingMaskIntoConstraints = false
        findPwdTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(pwdView.snp.leading).offset(20)
            make.top.equalTo(pwdView.snp.bottom).offset(8)
            make.height.equalTo(15)
        }
        findPwdTipLabel.text = "找回密码"
        findPwdTipLabel.textColor = UIColor.thirdLabelColor
        findPwdTipLabel.textAlignment = .left
        findPwdTipLabel.font = UIFont.systemFont(ofSize: 12)
        findPwdTipLabel.isUserInteractionEnabled = true
        let ges = UITapGestureRecognizer(target: self, action: #selector(clickResetPwd))
        findPwdTipLabel.addGestureRecognizer(ges)

        let registerTipLabel = UILabel()
        view.addSubview(registerTipLabel)
        registerTipLabel.translatesAutoresizingMaskIntoConstraints = false
        registerTipLabel.snp.makeConstraints { make in
            make.trailing.equalTo(pwdView.snp.trailing).offset(-20)
            make.top.equalTo(pwdView.snp.bottom).offset(15)
            make.height.equalTo(15)
        }
        registerTipLabel.text = "立即注册"
        registerTipLabel.textColor = UIColor.thirdLabelColor
        registerTipLabel.textAlignment = .right
        registerTipLabel.font = UIFont.systemFont(ofSize: 12)
        registerTipLabel.isUserInteractionEnabled = true
        let gest = UITapGestureRecognizer(target: self, action: #selector(clickRegister))
        registerTipLabel.addGestureRecognizer(gest)

        loginButton = UIButton()
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.snp.makeConstraints { make in
            make.width.equalTo(150)
            // 图片宽332 高308
            make.height.equalTo(150 * 308 / 332)
            make.top.equalTo(pwdView.snp.bottom).offset(80)
            make.centerX.equalToSuperview()
        }
        loginButton.setImage("icon-login-check".localImage, for: .normal)
        loginButton.adjustsImageWhenHighlighted = false
        loginButton.addTarget(self, action: #selector(clickLogin(button:)), for: .touchUpInside)
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

    @objc private func clickLogin(button: UIButton) {
        guard let email = emailField.text, let password = pwdField.text else { return }
        if email.count == 0 || password.count == 0 {
            presentAlert(title: "请填写完整信息", on: self)
            return
        }
        button.isEnabled = false
        let alert = UIAlertController(title: "正在登录", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "取消", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        let paras = ["email": email, "password": password]
        let config = WebAPIConfig(subspec: "user", function: "login")
        NetworkManager.shared.request(config: config, parameters: paras).responseModel { [weak self] (result: NetworkResult<BackDataWrapper<LoginBackData>>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.code == 0, let backData = res.data {
                        UserConfigManager.shared.saveValue(backData.token, to: .token)
                        UserConfigManager.shared.saveValue(email, to: .email)
                        UserConfigManager.shared.removeValue(of: .visitor)
                        alert.dismiss(animated: true, completion: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        alert.title = "登录失败"
                        alert.message = res.msg
                    }
                case .failure(_):
                    alert.title = "网络请求失败"
                }
                button.isEnabled = true
            }
        }
    }

    @objc private func clickResetPwd() {
        let vc = ResetPwdViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickRegister() {
        let vc = RegisterViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        emailField.resignFirstResponder()
        pwdField.resignFirstResponder()
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

fileprivate struct LoginBackData: Codable {
    var token: String
}
