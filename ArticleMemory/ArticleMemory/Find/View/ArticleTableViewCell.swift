//
//  ArticleTableViewCell.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/6/12.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    private var pdfID: String?

    var showActionSheet: ((UIViewController) -> Void)?
    var showAlert: ((UIViewController) -> Void)?
    var downloadPDF: (() -> Void)?
    var downloadWA: (() -> Void)?
    var downloadPDFAndWA: (() -> Void)?
    var longPress: (() -> Void)?

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let publishTimeLabel = UILabel()
    private let moreButton = UIButton()

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
        contentView.addSubview(iconImageView)
        contentView.addSubview(moreButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(publishTimeLabel)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        publishTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.width.height.equalTo(50)
            make.centerY.equalToSuperview()
        }
        iconImageView.image = "icon".localImage
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layer.cornerRadius = 5
        iconImageView.layer.masksToBounds = true

        moreButton.snp.makeConstraints { make in
            make.width.equalTo(57)
            make.top.bottom.trailing.equalToSuperview()
        }
        moreButton.setImage("icon-more".localImage?.resizeImage(size: CGSize(width: 32, height: 32)), for: .normal)
        moreButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 20)
        moreButton.addTarget(self, action: #selector(clickMore), for: .touchUpInside)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.trailing.equalTo(moreButton.snp.leading)
            make.top.equalTo(iconImageView.snp.top)
            make.height.equalTo(20)
        }
        titleLabel.textColor = UIColor.labelColor
        titleLabel.font = UIFont.systemFont(ofSize: 18)

        publishTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
            make.bottom.equalTo(iconImageView.snp.bottom)
            make.height.equalTo(20)
        }
        publishTimeLabel.textColor = UIColor.secondaryLabelColor
        publishTimeLabel.font = UIFont.systemFont(ofSize: 12)
    }

    func setupData(_ data: ArticleModel) {
        pdfID = data.pdfID
        titleLabel.text = data.title
        if data.publishTime.count > 10 {
            publishTimeLabel.text = data.publishTime[0..<10]
        } else {
            publishTimeLabel.text = data.publishTime
        }
        if let imgData = LocalFileManager.shared.getCover(name: data.pdfID) {
            iconImageView.image = UIImage(data: imgData)
        } else {
            DispatchQueue.global().async {
                // 如果cell已经被复用了，就先不用加载它的封面了
                guard self.pdfID == data.pdfID else { return }
                guard let url = data.coverImageURL, let imgData = try? Data(contentsOf: url) else { return }
                LocalFileManager.shared.saveCover(data: imgData, name: data.pdfID)
                DispatchQueue.main.async {
                    // 再次检验，保证封面确实是当前cell的，而不是已经被复用了的cell的
                    if self.pdfID == data.pdfID {
                        self.iconImageView.image = UIImage(data: imgData)
                    }
                }
            }
        }
    }

    @objc private func clickMore() {
        let vc = UIAlertController(title: titleLabel.text, message: nil, preferredStyle: .actionSheet)
        let downloadPDFButton = UIAlertAction(title: "下载PDF", style: .default, handler: { _ in
            self.downloadPDF?()
        })
        let downloadWAButton = UIAlertAction(title: "下载WA", style: .default, handler: { _ in
            self.downloadWA?()
        })
        let downloadBothButton = UIAlertAction(title: "下载PDF和WA", style: .default, handler: { _ in
            self.downloadPDFAndWA?()
        })
        let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        vc.addAction(downloadPDFButton)
        vc.addAction(downloadWAButton)
        vc.addAction(downloadBothButton)
        vc.addAction(cancelButton)
        // 若不设置此项，在iPad上会崩溃，https://blog.csdn.net/tsyccnh/article/details/52737367
        vc.popoverPresentationController?.barButtonItem = UIBarButtonItem(customView: moreButton)
        showActionSheet?(vc)
    }

    @objc private func longPressHandle(ges: UILongPressGestureRecognizer) {
        if ges.state == .began {
            self.longPress?()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        iconImageView.image = "icon".localImage
        publishTimeLabel.text = nil
        showActionSheet = nil
        showAlert = nil
        longPress = nil
    }
}
