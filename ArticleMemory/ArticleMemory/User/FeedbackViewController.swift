//
//  FeedbackViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/7/25.
//

import UIKit

class FeedbackViewController: AMUIViewController {

    private let textView = UITextView()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "反馈 & 建议"
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        textView.resignFirstResponder()
    }

    private func setup() {
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.snp.makeConstraints { make in
            make.leading.equalTo(30)
            make.trailing.equalTo(-30)
            make.top.equalTo(40 + NavBarH + StatusBarH)
            make.height.equalTo(250)
        }
        textView.backgroundColor = .white
        textView.textColor = UIColor.secondaryLabelColor
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.cornerRadius = 25
        textView.layer.borderWidth = 3
        textView.layer.borderColor = UIColor.thirdLabelColor.cgColor

        let button = UIButton()
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.snp.makeConstraints { make in
            make.width.equalTo(150)
            // 图片宽332 高308
            make.height.equalTo(150 * 308 / 332)
            make.top.equalTo(textView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        button.setImage("icon-login-check".localImage, for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(submit), for: .touchUpInside)
    }

    @objc private func submit() {
        guard let token = UserConfigManager.shared.getValue(of: .token) else { return }
        guard var feedback = textView.text, feedback.count > 0 else { return }
        let askAlert = UIAlertController(title: "确认提交？", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .default) { _ in
            let visitorEmail = UserConfigManager.shared.getValue(of: .visitorEmail) ?? "nil"
            let visitorPwd = UserConfigManager.shared.getValue(of: .visitorPassword) ?? "nil"
            let email = UserConfigManager.shared.getValue(of: .email) ?? ""
            feedback = "(token:\(token),visitorEmail:\(visitorEmail),visitorPassword:\(visitorPwd))" + feedback
            let alert = UIAlertController(title: "正在提交", message: nil, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let paras = ["feedback": feedback, "email": email]
            let config = WebAPIConfig(subspec: "user", function: "feedback")
            NetworkManager.shared.request(config: config, parameters: paras).responseModel { (result: NetworkResult<BackDataWrapper<CommonBackData>>) in
                DispatchQueue.main.async {
                    let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
                    alert.addAction(ok)
                    switch result {
                    case .success(let res):
                        if res.code == 0 {
                            alert.title = "提交成功"
                        } else {
                            alert.title = "提交失败"
                            alert.message = res.msg
                        }
                    case .failure(_):
                        alert.title = "网络请求失败"
                    }
                }
            }
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        askAlert.addAction(ok)
        askAlert.addAction(cancel)
        self.present(askAlert, animated: true, completion: nil)
    }
}
