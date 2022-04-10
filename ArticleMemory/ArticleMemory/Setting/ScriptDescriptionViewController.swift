//
//  ScriptDescriptionViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/10/16.
//

import UIKit

fileprivate let ScriptDescriptionTextFont = UIFont.systemFont(ofSize: 17)

class ScriptDescriptionViewController: AMUIViewController {

    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let autherLabel = UILabel()
    private let introTextView = UITextView()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .overCurrentContext
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.contentView.alpha = 1
        }, completion: nil)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if touches.first?.view == self.view {
            self.dismiss(animated: false, completion: nil)
        }
    }

    private func setup() {
        view.backgroundColor = UIColor.scriptDescriptionVCMaskColor
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp.makeConstraints { make in
            make.width.equalTo(ScreenWidth * 0.8)
            make.height.equalTo(ScreenWidth * 1.2)
            make.center.equalToSuperview()
        }
        contentView.backgroundColor = UIColor.backgroundWhite
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.scriptTextFieldBorderColor.cgColor
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
        contentView.alpha = 0

        contentView.addSubview(titleLabel)
        contentView.addSubview(autherLabel)
        contentView.addSubview(introTextView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        autherLabel.translatesAutoresizingMaskIntoConstraints = false
        introTextView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(8)
            make.trailing.equalTo(-8)
            make.top.equalTo(10)
            make.height.equalTo(45)
        }
        titleLabel.font = ScriptDescriptionTextFont
        titleLabel.layer.borderWidth = 1
        titleLabel.layer.borderColor = UIColor.scriptTextFieldBorderColor.cgColor
        titleLabel.layer.cornerRadius = 8
        titleLabel.layer.masksToBounds = true

        autherLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.height.equalTo(titleLabel)
        }
        autherLabel.font = ScriptDescriptionTextFont
        autherLabel.layer.borderWidth = 1
        autherLabel.layer.borderColor = UIColor.scriptTextFieldBorderColor.cgColor
        autherLabel.layer.cornerRadius = 8
        autherLabel.layer.masksToBounds = true

        introTextView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(autherLabel.snp.bottom).offset(10)
            make.bottom.equalTo(-10)
        }
        introTextView.backgroundColor = .clear
        introTextView.isEditable = false
        introTextView.isSelectable = false
        introTextView.layer.borderWidth = 1
        introTextView.layer.borderColor = UIColor.scriptTextFieldBorderColor.cgColor
        introTextView.layer.cornerRadius = 8
        introTextView.layer.masksToBounds = true
    }

    func setScriptModel(script: ScriptModel) {
        let titleAttributedString = NSMutableAttributedString(string: " 名称: ", attributes: [.foregroundColor: UIColor.scriptTextFieldTextHintColor])
        titleAttributedString.append(NSAttributedString(string: script.title, attributes: [.foregroundColor: UIColor.scriptTextFieldTextColor]))
        titleLabel.attributedText = titleAttributedString
        let autherAttributedString = NSMutableAttributedString(string: " 作者: ", attributes: [.foregroundColor: UIColor.scriptTextFieldTextHintColor])
        autherAttributedString.append(NSAttributedString(string: script.auther ?? "", attributes: [.foregroundColor: UIColor.scriptTextFieldTextColor]))
        autherLabel.attributedText = autherAttributedString
        let introAttributedString = NSMutableAttributedString(string: "简介: ", attributes: [.foregroundColor: UIColor.scriptTextFieldTextHintColor, .font: ScriptDescriptionTextFont])
        introAttributedString.append(NSAttributedString(string: script.introduction ?? "", attributes: [.foregroundColor: UIColor.scriptTextFieldTextColor, .font: ScriptDescriptionTextFont]))
        introTextView.attributedText = introAttributedString
    }
}
