//
//  EditScriptViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/10/15.
//

import UIKit

fileprivate let ScriptTextFont = UIFont.systemFont(ofSize: 17)

class EditScriptViewController: AMUIViewController {

    // script 为空则表示是正在新建脚本
    var script: ScriptModel? = nil

    private var isEdited: Bool = false {
        didSet {
            saveButton.isHidden = !isEdited
        }
    }

    private let titleTextField = UITextField()
    private let autherTextField = UITextField()
    private let introTextField = UITextField()
    private let codeTextView = UITextView()
    private let saveButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        titleTextField.resignFirstResponder()
        autherTextField.resignFirstResponder()
        introTextField.resignFirstResponder()
        codeTextView.resignFirstResponder()
    }

    private func setupNavigationItem() {
        let backButton = UIButton()
        backButton.frame = CGRect(x: 0, y: 0, width: 50, height: NavBarH)
        backButton.setImage("icon-back".localImage?.resizeImage(size: CGSize(width: 22, height: 22)), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 28)
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        saveButton.setTitle("保存", for: .normal)
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.addTarget(self, action: #selector(clickSave), for: .touchUpInside)
        saveButton.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }

    private func setup() {
        view.addSubview(titleTextField)
        view.addSubview(autherTextField)
        view.addSubview(introTextField)
        view.addSubview(codeTextView)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        autherTextField.translatesAutoresizingMaskIntoConstraints = false
        introTextField.translatesAutoresizingMaskIntoConstraints = false
        codeTextView.translatesAutoresizingMaskIntoConstraints = false

        titleTextField.snp.makeConstraints { make in
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.top.equalTo(StatusBarH + NavBarH + 10)
            make.height.equalTo(45)
        }
        autherTextField.snp.makeConstraints { make in
            make.leading.trailing.height.equalTo(titleTextField)
            make.top.equalTo(titleTextField.snp.bottom).offset(10)
        }
        introTextField.snp.makeConstraints { make in
            make.leading.trailing.height.equalTo(titleTextField)
            make.top.equalTo(autherTextField.snp.bottom).offset(10)
        }
        codeTextView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleTextField)
            make.top.equalTo(introTextField.snp.bottom).offset(10)
            make.bottom.equalTo(-20)
        }

        titleTextField.backgroundColor = UIColor.white
        titleTextField.text = script?.title
        titleTextField.attributedPlaceholder = NSAttributedString(string: "脚本名称", attributes: [.foregroundColor: UIColor.scriptTextFieldTextHintColor])
        titleTextField.textColor = UIColor.scriptTextFieldTextColor
        titleTextField.textAlignment = .left
        titleTextField.font = ScriptTextFont
        titleTextField.keyboardType = .default
        titleTextField.returnKeyType = .done
        titleTextField.autocorrectionType = .no
        titleTextField.autocapitalizationType = .none
        titleTextField.clearButtonMode = .whileEditing
        titleTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
        titleTextField.leftViewMode = .always
        titleTextField.delegate = self
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.scriptTextFieldBorderColor.cgColor
        titleTextField.layer.cornerRadius = 8
        titleTextField.layer.masksToBounds = true

        autherTextField.backgroundColor = UIColor.white
        autherTextField.text = script?.auther
        autherTextField.attributedPlaceholder = NSAttributedString(string: "脚本作者", attributes: [.foregroundColor: UIColor.scriptTextFieldTextHintColor])
        autherTextField.textColor = UIColor.scriptTextFieldTextColor
        autherTextField.textAlignment = .left
        autherTextField.font = ScriptTextFont
        autherTextField.keyboardType = .default
        autherTextField.returnKeyType = .done
        autherTextField.autocorrectionType = .no
        autherTextField.autocapitalizationType = .none
        autherTextField.clearButtonMode = .whileEditing
        autherTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
        autherTextField.leftViewMode = .always
        autherTextField.delegate = self
        autherTextField.layer.borderWidth = 1
        autherTextField.layer.borderColor = UIColor.scriptTextFieldBorderColor.cgColor
        autherTextField.layer.cornerRadius = 8
        autherTextField.layer.masksToBounds = true

        introTextField.backgroundColor = UIColor.white
        introTextField.text = script?.introduction
        introTextField.attributedPlaceholder = NSAttributedString(string: "脚本简介", attributes: [.foregroundColor: UIColor.scriptTextFieldTextHintColor])
        introTextField.textColor = UIColor.scriptTextFieldTextColor
        introTextField.textAlignment = .left
        introTextField.font = ScriptTextFont
        introTextField.keyboardType = .default
        introTextField.returnKeyType = .done
        introTextField.autocorrectionType = .no
        introTextField.autocapitalizationType = .none
        introTextField.clearButtonMode = .whileEditing
        introTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
        introTextField.leftViewMode = .always
        introTextField.delegate = self
        introTextField.layer.borderWidth = 1
        introTextField.layer.borderColor = UIColor.scriptTextFieldBorderColor.cgColor
        introTextField.layer.cornerRadius = 8
        introTextField.layer.masksToBounds = true

        codeTextView.backgroundColor = UIColor.white
        if let code = script?.code {
            codeTextView.text = code
        } else {
            codeTextView.text = "// JavaScript 代码"
        }
        codeTextView.textColor = UIColor.scriptTextFieldTextColor
        codeTextView.textAlignment = .left
        codeTextView.font = ScriptTextFont
        codeTextView.keyboardType = .default
        codeTextView.returnKeyType = .done
        codeTextView.autocorrectionType = .no
        codeTextView.autocapitalizationType = .none
        codeTextView.layer.borderWidth = 1
        codeTextView.layer.borderColor = UIColor.scriptTextFieldBorderColor.cgColor
        codeTextView.layer.cornerRadius = 8
        codeTextView.layer.masksToBounds = true
        codeTextView.delegate = self
    }

    @objc private func clickBack() {
        if script?.isEditable == false {
            self.navigationController?.popViewController(animated: true)
            return
        }
        if isEdited {
            let alertC = UIAlertController(title: "是否保存修改", message: nil, preferredStyle: .alert)
            let notSave = UIAlertAction(title: "不保存", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            let save = UIAlertAction(title: "保存", style: .default) { _ in
                self.clickSave()
                self.navigationController?.popViewController(animated: true)
            }
            alertC.addAction(notSave)
            alertC.addAction(save)
            self.present(alertC, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc private func clickSave() {
        if script?.isEditable == false {
            presentAlert(title: "此脚本不支持修改", message: nil, on: self)
            return
        }
        var title = titleTextField.text ?? "未命名"
        if title.count == 0 { title = "未命名" }
        if var theScript = script {
            theScript.title = title
            theScript.code = codeTextView.text
            theScript.auther = autherTextField.text
            theScript.introduction = introTextField.text
            ScriptManager.shared.modify(script: theScript)
            self.script = theScript
        } else {
            let theScript = ScriptModel(
                scriptId: "",
                title: title,
                code: codeTextView.text,
                isEnable: true,
                isEditable: true,
                auther: autherTextField.text,
                introduction: introTextField.text
            )
            ScriptManager.shared.add(scripts: [theScript])
            self.script = theScript
        }
        isEdited = false
        titleTextField.resignFirstResponder()
        autherTextField.resignFirstResponder()
        introTextField.resignFirstResponder()
        codeTextView.resignFirstResponder()
    }

}

extension EditScriptViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.isEdited = true
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.isEdited = true
        return true
    }
}

extension EditScriptViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.isEdited = true
    }
}
