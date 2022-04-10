//
//  FileTableViewCell.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/4/5.
//

import UIKit

class FileTableViewCell: UITableViewCell {

    var showActionSheet: ((UIViewController) -> Void)?
    var showAlert: ((UIViewController) -> Void)?
    var openOriginalWebpage: (() -> Void)?
    var shareFile: (() -> Void)?
    var renameFile: ((_ newTitle: String) -> Void)?
    var deleteFile: (() -> Void)?
    var longPress: (() -> Void)?

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let createTimeLabel = UILabel()
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
        contentView.addSubview(createTimeLabel)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        createTimeLabel.translatesAutoresizingMaskIntoConstraints = false

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
            make.width.equalTo(57) // 左5，右20，图片实际宽度32
            make.top.bottom.trailing.equalToSuperview()
        }
        moreButton.setImage("icon-more".localImage?.resizeImage(size: CGSize(width: 32, height: 32)), for: .normal)
        moreButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 20)
        moreButton.addTarget(self, action: #selector(clickMore), for: .touchUpInside)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(15)
            make.trailing.equalTo(moreButton.snp.leading).offset(-5)
            make.top.equalTo(iconImageView.snp.top).offset(4)
            make.height.equalTo(20)
        }
        titleLabel.textColor = UIColor.labelColor
        titleLabel.font = UIFont.systemFont(ofSize: 18)

        createTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(moreButton.snp.leading).offset(-5)
            make.bottom.equalTo(iconImageView.snp.bottom)
            make.height.equalTo(20)
        }
        createTimeLabel.textColor = UIColor.secondaryLabelColor
        createTimeLabel.font = UIFont.systemFont(ofSize: 12)
    }

    func setupData(_ data: FileModel) {
        if iconImageView.isAnimating {
            iconImageView.stopAnimating()
        }
        titleLabel.text = data.title
        if data.type == .local_pdf {
            iconImageView.image = "icon-pdf".localImage
            if data.createTime != nil && data.createTime!.count > 18 {
                createTimeLabel.text = data.createTime?[0..<19]
            } else {
                createTimeLabel.text = data.createTime
            }
        } else if data.type == .local_webarchive {
            iconImageView.image = "icon-webarchive".localImage
            if data.createTime != nil && data.createTime!.count > 18 {
                createTimeLabel.text = data.createTime?[0..<19]
            } else {
                createTimeLabel.text = data.createTime
            }
        } else if data.type == .local_png {
            iconImageView.image = "icon-png".localImage
            if data.createTime != nil && data.createTime!.count > 18 {
                createTimeLabel.text = data.createTime?[0..<19]
            } else {
                createTimeLabel.text = data.createTime
            }
        } else if data.type == .download_pdf {
            if let cover = data.cover {
                iconImageView.image = UIImage(data: cover)
            } else {
                iconImageView.image = "icon-pdf".localImage
            }
            if data.createTime != nil && data.createTime!.count > 10 {
                createTimeLabel.text = data.createTime?[0..<10]
            } else {
                createTimeLabel.text = data.createTime
            }
        } else {
            if let cover = data.cover {
                iconImageView.image = UIImage(data: cover)
            } else {
                iconImageView.image = "icon-webarchive".localImage
            }
            if data.createTime != nil && data.createTime!.count > 10 {
                createTimeLabel.text = data.createTime?[0..<10]
            } else {
                createTimeLabel.text = data.createTime
            }
        }
        if data.isDownloading {
            iconImageView.animationImages = LocalFileManager.shared.loadingGifImages
            iconImageView.animationDuration = 2
            iconImageView.animationRepeatCount = 0
            iconImageView.startAnimating()
        }
    }

    @objc private func clickMore() {
        let vc = UIAlertController(title: titleLabel.text, message: nil, preferredStyle: .actionSheet)

        let openOriginalWebpageButton = UIAlertAction(title: "打开原始网页", style: .default, handler: { _ in
            self.openOriginalWebpage?()
        })

        let share = UIAlertAction(title: "分享文件", style: .default) { _ in
            self.shareFile?()
        }

        let renameButton = UIAlertAction(title: "重命名", style: .default, handler: { _ in
            let alertC = UIAlertController(title: "重命名", message: nil, preferredStyle: .alert)
            alertC.addTextField(configurationHandler: { textField in
                textField.text = self.titleLabel.text
                textField.keyboardType = .default
                textField.returnKeyType = .done
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
                textField.delegate = self
            })
            let okButton = UIAlertAction(title: "确定", style: .default, handler: { _ in
                guard let newTitle = alertC.textFields?[0].text else { return }
                self.renameFile?(newTitle)
            })
            let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertC.addAction(okButton)
            alertC.addAction(cancelButton)
            self.showAlert?(alertC)
        })

        let deleteButton = UIAlertAction(title: "删除", style: .destructive, handler: { _ in
            let alertC = UIAlertController(title: "删除文件", message: "删除后将无法恢复", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "删除", style: .destructive, handler: { _ in
                self.deleteFile?()
            })
            let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertC.addAction(okButton)
            alertC.addAction(cancelButton)
            self.showAlert?(alertC)
        })

        let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        vc.addAction(openOriginalWebpageButton)
        vc.addAction(share)
        vc.addAction(renameButton)
        vc.addAction(deleteButton)
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
        iconImageView.image = nil
        createTimeLabel.text = nil
        showActionSheet = nil
        showAlert = nil
        openOriginalWebpage = nil
        shareFile = nil
        renameFile = nil
        deleteFile = nil
        longPress = nil
        if iconImageView.isAnimating {
            iconImageView.stopAnimating()
        }
    }
}

extension FileTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
