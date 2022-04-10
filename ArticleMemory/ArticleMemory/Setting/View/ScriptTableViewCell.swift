//
//  ScriptTableViewCell.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/10/13.
//

import UIKit

class ScriptTableViewCell: UITableViewCell {

    var changeSwitchValue: ((_ isOn: Bool) -> Void)?
    var editScript: (() -> Void)?
    var longPress: (() -> Void)?

    private let titleLabel = UILabel()
    private let editButton = UIButton()
    private let switchButton = UISwitch()

    private var longPressGes: UILongPressGestureRecognizer!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandle(ges:)))
        longPressGes.minimumPressDuration = TableViewCellLongPressGesMinimumPressDuration
        self.addGestureRecognizer(longPressGes)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.backgroundColor = .clear
        contentView.addSubview(titleLabel)
        contentView.addSubview(editButton)
        contentView.addSubview(switchButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.translatesAutoresizingMaskIntoConstraints = false

        switchButton.snp.makeConstraints { make in
            // UISwitch 有默认的大小，且无法改变
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-15)
        }
        switchButton.addTarget(self, action: #selector(switchValueChanged(switchButton:)), for: .valueChanged)

        editButton.snp.makeConstraints { make in
            make.trailing.equalTo(switchButton.snp.leading).offset(-5)
            make.width.equalTo(38)
            make.top.bottom.equalToSuperview()
        }
        editButton.setImage("icon-script-edit".localImage?.resizeImage(size: CGSize(width: 28, height: 28)), for: .normal)
        editButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        editButton.addTarget(self, action: #selector(clickEdit), for: .touchUpInside)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(editButton.snp.leading)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.labelColor
        titleLabel.font = UIFont.systemFont(ofSize: 18)
    }

    func setupData(_ data: ScriptModel) {
        titleLabel.text = data.title
        switchButton.isOn = data.isEnable
    }

    @objc private func switchValueChanged(switchButton: UISwitch) {
        self.changeSwitchValue?(switchButton.isOn)
    }

    @objc private func clickEdit() {
        self.editScript?()
    }

    @objc private func longPressHandle(ges: UILongPressGestureRecognizer) {
        if ges.state == .began {
            self.longPress?()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        changeSwitchValue = nil
        editScript = nil
        longPress = nil
    }

}
