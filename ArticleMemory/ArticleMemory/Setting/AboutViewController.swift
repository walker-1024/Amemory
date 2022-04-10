//
//  AboutViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/7/27.
//

import UIKit

class AboutViewController: AMUIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "关于"
        setupButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setupButtons() {
        let versionLogButton = ShadowButtonView()
        view.addSubview(versionLogButton)
        versionLogButton.translatesAutoresizingMaskIntoConstraints = false
        versionLogButton.snp.makeConstraints { make in
            make.top.equalTo(30 + NavBarH + StatusBarH)
            make.height.equalTo(CommonShadowButtonHeight)
            make.width.equalTo(CommonShadowButtonWidth)
            make.centerX.equalToSuperview()
        }
        versionLogButton.text = "版本日志"
        versionLogButton.gesture = UITapGestureRecognizer(target: self, action: #selector(clickVersionLog))

        let privacyButton = ShadowButtonView()
        view.addSubview(privacyButton)
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.snp.makeConstraints { make in
            make.top.equalTo(versionLogButton.snp.bottom).offset(-10)
            make.height.equalTo(CommonShadowButtonHeight)
            make.width.equalTo(CommonShadowButtonWidth)
            make.centerX.equalToSuperview()
        }
        privacyButton.text = "隐私声明"
        privacyButton.gesture = UITapGestureRecognizer(target: self, action: #selector(clickPrivacy))

        let disclaimersButton = ShadowButtonView()
        view.addSubview(disclaimersButton)
        disclaimersButton.translatesAutoresizingMaskIntoConstraints = false
        disclaimersButton.snp.makeConstraints { make in
            make.top.equalTo(privacyButton.snp.bottom).offset(-10)
            make.height.equalTo(CommonShadowButtonHeight)
            make.width.equalTo(CommonShadowButtonWidth)
            make.centerX.equalToSuperview()
        }
        disclaimersButton.text = "免责声明"
        disclaimersButton.gesture = UITapGestureRecognizer(target: self, action: #selector(clickDisclaimers))
    }

    @objc private func clickVersionLog() {
        let vc = VersionLogViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickPrivacy() {
        let vc = WebpageViewController()
        vc.isSaveButtonHidden = true
        vc.load(str: StaticWebpageUrlPrivacy)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func clickDisclaimers() {
        let vc = WebpageViewController()
        vc.isSaveButtonHidden = true
        vc.load(str: StaticWebpageUrlDisclaimers)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
