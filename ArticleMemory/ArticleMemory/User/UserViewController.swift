//
//  UserViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/3/27.
//

import UIKit

class UserViewController: AMUIViewController {

    private let profileView = UIView()
    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let pointButton = ShadowButtonView()
    private let adminButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfile()
        setupButtons()

        view.addSubview(adminButton)
        adminButton.frame = CGRect(x: 100, y: 150, width: 80, height: 40)
        adminButton.backgroundColor = UIColor.secondaryLabelColor
        adminButton.setTitle("管理员", for: .normal)
        adminButton.setTitleColor(.black, for: .normal)
        adminButton.addTarget(self, action: #selector(clickAdmin), for: .touchUpInside)
        adminButton.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(refreshProfile), name: .needRefreshProfile, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        VisitorManager.checkVisitorAccount()
        guard let _ = UserConfigManager.shared.getValue(of: .token) else { return }
        if let username = UserConfigManager.shared.getValue(of: .username) {
            usernameLabel.text = username
        }
        if let imageData = LocalFileManager.shared.getAvatar() {
            avatarImageView.image = UIImage(data: imageData)
        } else {
            avatarImageView.image = "icon".localImage
        }
        refreshProfile()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        adminButton.isHidden = true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupProfile() {
        view.addSubview(profileView)
        profileView.translatesAutoresizingMaskIntoConstraints = false
        profileView.snp.makeConstraints { make in
            make.top.equalTo(50)
            make.height.equalTo(120)
            make.width.equalTo(350)
            make.centerX.equalToSuperview()
        }
        let ges = UITapGestureRecognizer(target: self, action: #selector(clickLogin))
        profileView.addGestureRecognizer(ges)

        profileView.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalTo(10)
            make.width.height.equalTo(80)
            make.centerY.equalToSuperview()
        }
        avatarImageView.image = "icon".localImage
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.layer.masksToBounds = true
        avatarImageView.isUserInteractionEnabled = true
        let gest = UITapGestureRecognizer(target: self, action: #selector(clickAvatar))
        avatarImageView.addGestureRecognizer(gest)

        let signView = UIImageView()
        profileView.addSubview(signView)
        signView.isUserInteractionEnabled = true
        signView.translatesAutoresizingMaskIntoConstraints = false
        signView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(60)
            make.centerY.equalToSuperview()
        }
        signView.image = "icon-shadow-button".localImage
        signView.contentMode = .scaleToFill

        let signButton = UIButton()
        signView.addSubview(signButton)
        signButton.translatesAutoresizingMaskIntoConstraints = false
        signButton.snp.makeConstraints { make in
            make.leading.equalTo(5)
            make.trailing.equalTo(-5)
            make.height.equalTo(50)
            make.centerY.equalToSuperview()
        }
        signButton.setTitle("签到", for: .normal)
        signButton.setTitleColor(UIColor.shadowButtonTitleColor, for: .normal)
        signButton.addTarget(self, action: #selector(clickSign(button:)), for: .touchUpInside)

        profileView.addSubview(usernameLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(15)
            make.bottom.equalTo(profileView.snp.centerY).offset(-5)
            make.height.equalTo(30)
            make.trailing.equalTo(signButton.snp.leading).offset(-5)
        }
        usernameLabel.text = "游客"
        usernameLabel.textAlignment = .left
        usernameLabel.textColor = UIColor.labelColor
        usernameLabel.font = UIFont.systemFont(ofSize: 20)

        let tipLabel = UILabel()
        profileView.addSubview(tipLabel)
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.snp.makeConstraints { make in
            make.leading.equalTo(usernameLabel)
            make.trailing.equalTo(usernameLabel)
            make.top.equalTo(profileView.snp.centerY).offset(5)
            make.height.equalTo(20)
        }
        tipLabel.text = "点击头像修改资料"
        tipLabel.textAlignment = .left
        tipLabel.textColor = UIColor.thirdLabelColor
        tipLabel.font = UIFont.systemFont(ofSize: 12)

    }

    private func setupButtons() {
        view.addSubview(pointButton)
        pointButton.translatesAutoresizingMaskIntoConstraints = false
        pointButton.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(20)
            make.height.equalTo(CommonShadowButtonHeight)
            make.width.equalTo(CommonShadowButtonWidth)
            make.centerX.equalToSuperview()
        }
        pointButton.image = "icon-memory-fragment".localImage
        pointButton.text = "记忆碎片： "
        pointButton.gesture = UITapGestureRecognizer(target: self, action: #selector(clickCharge))

        let qaButton = ShadowButtonView()
        view.addSubview(qaButton)
        qaButton.translatesAutoresizingMaskIntoConstraints = false
        qaButton.snp.makeConstraints { make in
            make.top.equalTo(pointButton.snp.bottom).offset(-10)
            make.height.equalTo(CommonShadowButtonHeight)
            make.width.equalTo(CommonShadowButtonWidth)
            make.centerX.equalToSuperview()
        }
        qaButton.image = "icon-qa".localImage
        qaButton.text = "常见问题"
        qaButton.gesture = UITapGestureRecognizer(target: self, action: #selector(clickQA))

        let feedbackButton = ShadowButtonView()
        view.addSubview(feedbackButton)
        feedbackButton.translatesAutoresizingMaskIntoConstraints = false
        feedbackButton.snp.makeConstraints { make in
            make.top.equalTo(qaButton.snp.bottom).offset(-10)
            make.height.equalTo(CommonShadowButtonHeight)
            make.width.equalTo(CommonShadowButtonWidth)
            make.centerX.equalToSuperview()
        }
        feedbackButton.image = "icon-feedback".localImage
        feedbackButton.text = "反馈 & 建议"
        feedbackButton.gesture = UITapGestureRecognizer(target: self, action: #selector(clickFeedback))

        let settingButton = ShadowButtonView()
        view.addSubview(settingButton)
        settingButton.translatesAutoresizingMaskIntoConstraints = false
        settingButton.snp.makeConstraints { make in
            make.top.equalTo(feedbackButton.snp.bottom).offset(-10)
            make.height.equalTo(CommonShadowButtonHeight)
            make.width.equalTo(CommonShadowButtonWidth)
            make.centerX.equalToSuperview()
        }
        settingButton.image = "icon-setting".localImage
        settingButton.text = "设置"
        settingButton.gesture = UITapGestureRecognizer(target: self, action: #selector(clickSetting))

        let logoutButton = ShadowButtonView()
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(settingButton.snp.bottom).offset(-10)
            make.height.equalTo(CommonShadowButtonHeight)
            make.width.equalTo(CommonShadowButtonWidth)
            make.centerX.equalToSuperview()
        }
        logoutButton.image = "icon-logout".localImage
        logoutButton.text = "退出登录"
        logoutButton.gesture = UITapGestureRecognizer(target: self, action: #selector(clickLogout))
    }

    @objc private func refreshProfile() {
        // 刷新用户信息
        let config = WebAPIConfig(subspec: "user", function: "info")
        NetworkManager.shared.request(config: config).responseModel { [weak self] (result: NetworkResult<BackDataWrapper<UserInfoBackData>>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.code == 0, let backData = res.data {
                        if backData.name == "" {
                            if UserConfigManager.shared.getBoolValue(of: .visitor) {
                                self.usernameLabel.text = "游客"
                            } else {
                                self.usernameLabel.text = "未设置用户名"
                            }
                        } else {
                            self.usernameLabel.text = backData.name
                            UserConfigManager.shared.saveValue(backData.name, to: .username)
                        }
                        self.pointButton.text = "记忆碎片： \(backData.point)"
                        if backData.identity > 0 {
                            self.adminButton.isHidden = false
                        }
                        DispatchQueue.global().async {
                            if LocalFileManager.shared.isNeedUpdateAvatar(md5: backData.avatarHash) {
                                if let url = URL(string: backData.avatarPath), let imageData = try? Data(contentsOf: url) {
                                    DispatchQueue.main.async {
                                        self.avatarImageView.image = UIImage(data: imageData)
                                        LocalFileManager.shared.saveAvatar(data: imageData)
                                    }
                                }
                            }
                        }
                    } else if res.code == -2 {
                        // 登录过期
                        presentAlert(title: res.msg, on: self)
                        self.usernameLabel.text = "游客"
                        self.avatarImageView.image = "icon".localImage
                        UserConfigManager.shared.removeValue(of: .token)
                        UserConfigManager.shared.removeValue(of: .username)
                        VisitorManager.checkVisitorAccount()
                    } else {
                        self.usernameLabel.text = "游客"
                        self.avatarImageView.image = "icon".localImage
                        UserConfigManager.shared.removeValue(of: .token)
                        UserConfigManager.shared.removeValue(of: .username)
                        VisitorManager.checkVisitorAccount()
                    }
                case .failure(_):
                    break
                }
            }
        }
    }

    @objc private func clickAvatar() {
        if UserConfigManager.shared.getBoolValue(of: .visitor) || UserConfigManager.shared.getValue(of: .token) == nil {
            clickLogin()
            return
        }
        let vc = ModifyProfileViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickLogin() {
        if UserConfigManager.shared.getBoolValue(of: .visitor) || UserConfigManager.shared.getValue(of: .token) == nil {
            let vc = LoginViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func clickSign(button: UIButton) {
        guard let _ = UserConfigManager.shared.getValue(of: .token) else {
            clickLogin()
            return
        }
        button.isEnabled = false
        let config = WebAPIConfig(subspec: "user", function: "sign")
        NetworkManager.shared.request(config: config).responseModel { [weak self] (result: NetworkResult<BackDataWrapper<SignBackData>>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.code == 0, let backData = res.data {
                        let tip = "本次获得\(backData.reward)碎片\n一共拥有\(backData.point)碎片"
                        self.pointButton.text = "记忆碎片： \(backData.point)"
                        presentAlert(title: "签到", message: tip, on: self)
                    } else if res.code == 2010 {
                        let tip = "今天已经签过到了哦"
                        presentAlert(title: "签到", message: tip, on: self)
                    } else {
                        presentAlert(title: "签到失败", message: res.msg, on: self)
                    }
                case .failure(_):
                    presentAlert(title: "网络请求失败", on: self)
                }
                button.isEnabled = true
            }
        }
    }

    @objc private func clickCharge() {
        // 关闭充值中心入口
        presentAlert(title: "充值中心已关闭", on: self)
        return
        guard let _ = UserConfigManager.shared.getValue(of: .token) else { return }
        if UserConfigManager.shared.getBoolValue(of: .visitor) {
            let alert = UIAlertController(title: "您正以游客身份登录", message: "您的相关数据正保存在本地，您可以通过登录以在您的多个设备之间同步数据。", preferredStyle: .alert)
            let goRegister = UIAlertAction(title: "去登录", style: .default) { _ in
                let vc = LoginViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let cancel = UIAlertAction(title: "暂不登录", style: .cancel) { _ in
                let vc = ChargeCenterViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            alert.addAction(goRegister)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let vc = ChargeCenterViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickQA() {
        let vc = WebpageViewController()
        vc.isSaveButtonHidden = true
        vc.load(str: StaticWebpageUrlQA)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickFeedback() {
        let vc = FeedbackViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickSetting() {
        let vc = SettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickLog() {
        let vc = VersionLogViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickLogout() {
        guard let _ = UserConfigManager.shared.getValue(of: .token) else { return }
        if UserConfigManager.shared.getBoolValue(of: .visitor) { return }
        let alert = UIAlertController(title: "退出登录", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .default, handler: { _ in
            self.usernameLabel.text = "游客"
            self.avatarImageView.image = "icon".localImage
            self.pointButton.text = "记忆碎片： "
            UserConfigManager.shared.removeValue(of: .token)
            UserConfigManager.shared.removeValue(of: .username)
            VisitorManager.checkVisitorAccount()
        })
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    @objc private func clickAdmin() {
        // some code has been deleted
    }

}

fileprivate struct UserInfoBackData: Codable {
    var name: String
    var email: String
    var avatarHash: String
    var avatarPath: String
    var point: Int
    var identity: Int // 0为普通用户，1为管理员，2为超级管理员
}

fileprivate struct SignBackData: Codable {
    var reward: Int
    var point: Int
}
