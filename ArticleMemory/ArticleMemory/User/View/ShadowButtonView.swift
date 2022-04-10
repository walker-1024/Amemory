//
//  ShadowButtonView.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/7/25.
//

import UIKit

class ShadowButtonView: UIView {

    var image: UIImage? {
        didSet {
            icon.image = image
        }
    }
    var text: String? {
        didSet {
            label.text = text
        }
    }
    var gesture: UIGestureRecognizer? {
        didSet {
            if oldValue != nil {
                self.removeGestureRecognizer(oldValue!)
            }
            if gesture != nil {
                self.addGestureRecognizer(gesture!)
            }
        }
    }

    private let icon = UIImageView()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let shadowView = UIImageView()
        self.addSubview(shadowView)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        shadowView.image = "icon-shadow-button".localImage
        shadowView.contentMode = .scaleToFill

        self.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.snp.makeConstraints { make in
            make.leading.equalTo(35)
            make.width.height.equalTo(28)
            make.centerY.equalToSuperview()
        }
        icon.contentMode = .scaleAspectFit

        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(15)
            make.trailing.equalTo(-35)
            make.height.equalTo(45)
            make.centerY.equalToSuperview()
        }
        label.textAlignment = .left
        label.textColor = UIColor.shadowButtonTitleColor
        label.font = UIFont.systemFont(ofSize: 18)
    }
}
