//
//  CommodityView.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/10/12.
//

import UIKit

class CommodityView: UIView {

    var iconImage: UIImage? {
        didSet {
            icon.image = iconImage
        }
    }
    var nameLabelText: String? {
        didSet {
            nameLabel.text = nameLabelText
        }
    }
    var priceLabelText: String? {
        didSet {
            priceLabel.text = priceLabelText
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
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()

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

        shadowView.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.snp.makeConstraints { make in
            make.leading.equalTo(40)
            make.width.height.equalTo(32)
            make.bottom.equalTo(shadowView.snp.centerY).offset(-10)
        }

        shadowView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(15)
            make.trailing.equalTo(-40)
            make.height.equalTo(32)
            make.centerY.equalTo(icon)
        }
        nameLabel.textAlignment = .left
        nameLabel.textColor = UIColor.shadowButtonTitleColor
        nameLabel.font = UIFont.systemFont(ofSize: 15)

        shadowView.addSubview(priceLabel)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(20)
            make.trailing.equalTo(-40)
            make.height.equalTo(32)
            make.top.equalTo(shadowView.snp.centerY).offset(10)
        }
        priceLabel.textAlignment = .left
        priceLabel.textColor = UIColor.shadowButtonTitleColor
        priceLabel.font = UIFont.systemFont(ofSize: 15)
    }
}
