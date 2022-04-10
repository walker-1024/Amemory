//
//  ModifyProfileViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/7/25.
//

import UIKit

class ModifyProfileViewController: AMUIViewController {

    private let avatar = UIImageView()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "修改个人资料"
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setup() {
        view.addSubview(avatar)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.snp.makeConstraints { make in
            make.top.equalTo(50 + NavBarH + StatusBarH)
            make.width.height.equalTo(100)
            make.centerX.equalToSuperview()
        }
        if let imageData = LocalFileManager.shared.getAvatar() {
            avatar.image = UIImage(data: imageData)
        } else {
            avatar.image = "icon".localImage
        }
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = 50
        avatar.layer.masksToBounds = true
        avatar.isUserInteractionEnabled = true
        let ges = UITapGestureRecognizer(target: self, action: #selector(clickAvatar))
        avatar.addGestureRecognizer(ges)

        let usernameView = UIImageView()
        view.addSubview(usernameView)
        usernameView.isUserInteractionEnabled = true
        usernameView.translatesAutoresizingMaskIntoConstraints = false
        usernameView.snp.makeConstraints { make in
            make.top.equalTo(avatar.snp.bottom).offset(30)
            make.height.equalTo(CommonShadowButtonHeight)
            make.width.equalTo(CommonShadowButtonWidth)
            make.centerX.equalToSuperview()
        }
        usernameView.image = "icon-shadow-button".localImage
        usernameView.contentMode = .scaleToFill

        let usernameButton = UIButton()
        usernameView.addSubview(usernameButton)
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        usernameButton.snp.makeConstraints { make in
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(60)
            make.centerY.equalToSuperview()
        }
        usernameButton.setTitle("修改用户名", for: .normal)
        usernameButton.setTitleColor(UIColor.shadowButtonTitleColor, for: .normal)
        usernameButton.addTarget(self, action: #selector(clickUsername), for: .touchUpInside)

        let resetPwdView = UIImageView()
        view.addSubview(resetPwdView)
        resetPwdView.isUserInteractionEnabled = true
        resetPwdView.translatesAutoresizingMaskIntoConstraints = false
        resetPwdView.snp.makeConstraints { make in
            make.top.equalTo(usernameView.snp.bottom)
            make.height.equalTo(CommonShadowButtonHeight)
            make.width.equalTo(CommonShadowButtonWidth)
            make.centerX.equalToSuperview()
        }
        resetPwdView.image = "icon-shadow-button".localImage
        resetPwdView.contentMode = .scaleToFill

        let resetPwdButton = UIButton()
        resetPwdView.addSubview(resetPwdButton)
        resetPwdButton.translatesAutoresizingMaskIntoConstraints = false
        resetPwdButton.snp.makeConstraints { make in
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.height.equalTo(60)
            make.centerY.equalToSuperview()
        }
        resetPwdButton.setTitle("重置密码", for: .normal)
        resetPwdButton.setTitleColor(UIColor.shadowButtonTitleColor, for: .normal)
        resetPwdButton.addTarget(self, action: #selector(clickResetPwd), for: .touchUpInside)
    }

    @objc private func clickAvatar() {
        // 先判断是否有权限
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }

    private func resetAvatar(image: UIImage) {
        guard let imageData = image.pngData() else { return }

        let alertC = UIAlertController(title: "正在上传", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel) { _ in

        }
        alertC.addAction(cancel)
        self.present(alertC, animated: true, completion: nil)

        let config = WebAPIConfig(subspec: "user", function: "resetAvatar")
        let files = [UploadFile(key: "avatar", data: imageData, fileName: "avatar", mimeType: "image/png")]
        NetworkManager.shared.upload(config: config, files: files, headers: ["Content-Type": "multipart/form-data"]) { [weak self] (result: NetworkResult<BackDataWrapper<ResetAvatarBackData>>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    if model.code == 0 {
                        self.avatar.image = image
                        LocalFileManager.shared.saveAvatar(data: imageData)
                        alertC.dismiss(animated: true, completion: nil)
                    } else {
                        alertC.title = "请求失败"
                        alertC.message = model.msg
                    }
                case .failure(_):
                    alertC.title = "网络请求失败"
                }
            }
        }
    }

    @objc private func clickUsername() {
        let username = UserConfigManager.shared.getValue(of: .username)
        let alert = UIAlertController(title: "修改用户名", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.text = username
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.delegate = self
        })
        let okButton = UIAlertAction(title: "确定", style: .default, handler: { _ in
            guard let newName = alert.textFields?[0].text else { return }
            let paras = ["name": newName]
            let config = WebAPIConfig(subspec: "user", function: "resetUsername")
            NetworkManager.shared.request(config: config, parameters: paras).responseModel { [weak self] (result: NetworkResult<BackDataWrapper<CommonBackData>>) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let res):
                        if res.code == 0 {
                            UserConfigManager.shared.saveValue(newName, to: .username)
                            presentAlert(title: "修改成功", on: self)
                        } else {
                            presentAlert(title: "修改失败", message: res.msg, on: self)
                        }
                    case .failure(_):
                        presentAlert(title: "网络请求失败", on: self)
                    }
                }
            }
        })
        let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }

    @objc private func clickResetPwd() {
        let vc = ResetPwdViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ModifyProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ModifyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            picker.dismiss(animated: true, completion: {
                self.resetAvatar(image: image)
            })
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

fileprivate struct ResetAvatarBackData: Codable {
    var avatarHash: String
}
