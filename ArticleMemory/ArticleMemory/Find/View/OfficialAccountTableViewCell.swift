//
//  OfficialAccountTableViewCell.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/6/11.
//

import UIKit

class OfficialAccountTableViewCell: UITableViewCell {

    var biz: String!

    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let countLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.backgroundColor = .clear
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(countLabel)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.width.height.equalTo(50)
            make.centerY.equalToSuperview()
        }
        iconImageView.image = "icon".localImage
        iconImageView.layer.cornerRadius = 5
        iconImageView.layer.masksToBounds = true

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(20)
            make.trailing.equalTo(-10)
            make.top.equalTo(iconImageView.snp.top)
            make.height.equalTo(20)
        }
        nameLabel.textColor = UIColor.labelColor
        nameLabel.font = UIFont.systemFont(ofSize: 18)

        countLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.leading)
            make.trailing.equalTo(-10)
            make.bottom.equalTo(iconImageView.snp.bottom)
            make.height.equalTo(20)
        }
        countLabel.textColor = UIColor.secondaryLabelColor
        countLabel.font = UIFont.systemFont(ofSize: 12)
    }

    func setupData(_ data: OfficialAccountModel) {
        biz = data.biz
        nameLabel.text = data.name
        countLabel.text = "共 \(data.articleCount) 篇历史文章"
        if let imgData = LocalFileManager.shared.getCover(name: data.biz) {
            iconImageView.image = UIImage(data: imgData)
        } else {
            DispatchQueue.global().async {
                // 如果cell已经被复用了，就先不用加载它的封面了
                guard self.biz == data.biz else { return }
                guard let url = data.coverImageURL, let imgData = try? Data(contentsOf: url) else { return }
                LocalFileManager.shared.saveCover(data: imgData, name: data.biz)
                DispatchQueue.main.async {
                    // 再次检验，保证封面确实是当前cell的，而不是已经被复用了的cell的
                    if self.biz == data.biz {
                        self.iconImageView.image = UIImage(data: imgData)
                    }
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        iconImageView.image = "icon".localImage
        countLabel.text = nil
    }
}
