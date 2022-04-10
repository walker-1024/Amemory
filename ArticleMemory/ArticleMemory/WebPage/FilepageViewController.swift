//
//  FilepageViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/7/3.
//

import UIKit
import WebKit

class FilepageViewController: AMUIViewController {

    var fileModel: FileModel?

    private let webView = WKWebView()
    private let funcButton = UIButton()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setup()
        guard let file = fileModel else { return }
        let filePath = LocalFileManager.shared.getFilePath(pdfID: file.pdfID, fileType: file.type.rawValue)
        self.load(path: filePath)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setupNavigationItem() {        
        funcButton.setImage("icon-more-v".localImage?.resizeImage(size: CGSize(width: 28, height: 28)), for: .normal)
        funcButton.addTarget(self, action: #selector(clickMore), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: funcButton)
    }

    private func setup() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.snp.makeConstraints { make in
            make.top.equalTo(StatusBarH + NavBarH)
            make.leading.trailing.bottom.equalToSuperview()
        }

        let config = webView.configuration
        config.allowsInlineMediaPlayback = true

        webView.uiDelegate = self
        webView.navigationDelegate = self
    }

    func load(path: String) {
        webView.load(URLRequest(url: URL(fileURLWithPath: path)))
    }

    func load(url: URL) {
        webView.load(URLRequest(url: url))
    }

    @objc private func clickBack() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc private func clickMore() {
        let alertC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let share = UIAlertAction(title: "分享文件", style: .default) { _ in
            guard let fileModel = self.fileModel else { return }
            let fileUrls = LocalFileManager.shared.getShareFileUrls(files: [fileModel])
            let activityVC = UIActivityViewController(activityItems: fileUrls, applicationActivities: nil)
            activityVC.popoverPresentationController?.barButtonItem = UIBarButtonItem(customView: self.funcButton)
            self.present(activityVC, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertC.addAction(share)
        alertC.addAction(cancel)
        alertC.popoverPresentationController?.barButtonItem = UIBarButtonItem(customView: funcButton)
        self.present(alertC, animated: true, completion: nil)
    }

}

extension FilepageViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("页面开始加载")
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("页面加载失败")
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("内容开始返回")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("页面加载完成")
    }
}
