//
//  WebpageViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/4/4.
//

import UIKit
import WebKit

class WebpageViewController: AMUIViewController {

    var isSaveButtonHidden: Bool = false {
        didSet { saveButton.isHidden = isSaveButtonHidden }
    }

    private let webView = WKWebView()
    private let saveButton = UIButton()

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setupNavigationItem() {
        saveButton.setImage("icon-more-v".localImage?.resizeImage(size: CGSize(width: 28, height: 28)), for: .normal)
        saveButton.addTarget(self, action: #selector(clickMore), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }

    private func setup() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        if UserConfigManager.shared.getBoolValue(of: .webVCNavBarBlur){
            webView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            webView.snp.makeConstraints { make in
                make.top.equalTo(StatusBarH + NavBarH)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }

        let config = webView.configuration
        config.allowsInlineMediaPlayback = true

        webView.uiDelegate = self
        webView.navigationDelegate = self
    }

    func load(str: String) {
        guard let url = URL(string: str) else { return }
        webView.load(URLRequest(url: url))
    }

    func load(url: URL) {
        webView.load(URLRequest(url: url))
    }

    private func createImage() {
        guard let urlString = webView.url?.absoluteString else { return }
        let title = webView.title ?? ""

        let alertC = UIAlertController(title: "正在保存。。。", message: nil, preferredStyle: .alert)
        self.present(alertC, animated: true, completion: nil)

        self.webView.createPDF { result in
            switch result {
            case .success(let data):
                var res = false
                if let pngData = PDFProcessor.shared.convertPdfToImage(data: data) {
                    res = LocalFileManager.shared.saveLocalFile(data: pngData, type: .local_png, title: title, url: urlString)
                }
                if res {
                    alertC.title = "保存成功"
                } else {
                    alertC.title = "保存失败"
                }
                let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
                alertC.addAction(ok)
            case .failure(let error):
                print(error)
                alertC.title = "保存失败"
                let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
                alertC.addAction(ok)
            }
        }
    }

    private func createPDF() {
        guard let urlString = webView.url?.absoluteString else { return }
        let title = webView.title ?? ""

        let alertC = UIAlertController(title: "正在保存。。。", message: nil, preferredStyle: .alert)
        self.present(alertC, animated: true, completion: nil)

        self.webView.createPDF { result in
            switch result {
            case .success(let data):
                var pdfData: Data!
                switch UserConfigManager.shared.getIntValue(of: .pdfPageSplit) {
                case -1:
                    pdfData = PDFProcessor.shared.convertMultiPageToSinglePage(data: data) ?? data
                case -4:
                    let ratioWidth = CGFloat(UserConfigManager.shared.getFloatValue(of: .pdfPageSplitWidth))
                    let ratioHeight = CGFloat(UserConfigManager.shared.getFloatValue(of: .pdfPageSplitHeight))
                    let singlePagePdfData = PDFProcessor.shared.convertMultiPageToSinglePage(data: data) ?? data
                    pdfData = PDFProcessor.shared.convertSinglePageToMultiPage(data: singlePagePdfData, ratioWidth: ratioWidth, ratioHeight: ratioHeight) ?? data
                default:
                    pdfData = data
                }
                let res = LocalFileManager.shared.saveLocalFile(data: pdfData, type: .local_pdf, title: title, url: urlString)
                if res {
                    alertC.title = "保存成功"
                } else {
                    alertC.title = "保存失败"
                }
                let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
                alertC.addAction(ok)
            case .failure(let error):
                print(error)
                alertC.title = "保存失败"
                let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
                alertC.addAction(ok)
            }
        }
    }

    private func createWebArchive() {
        guard let urlString = webView.url?.absoluteString else { return }
        let title = webView.title ?? ""

        let alertC = UIAlertController(title: "正在保存。。。", message: nil, preferredStyle: .alert)
        self.present(alertC, animated: true, completion: nil)

        self.webView.createWebArchiveData { result in
            switch result {
            case .success(let data):
                let res = LocalFileManager.shared.saveLocalFile(data: data, type: .local_webarchive, title: title, url: urlString)
                if res {
                    alertC.title = "保存成功"
                } else {
                    alertC.title = "保存失败"
                }
                let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
                alertC.addAction(ok)
            case .failure(let error):
                print(error)
                alertC.title = "保存失败"
                let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
                alertC.addAction(ok)
            }
        }
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
        let pdf = UIAlertAction(title: "保存为PDF", style: .default, handler: { _ in
            self.createPDF()
        })
        let image = UIAlertAction(title: "保存为图片", style: .default) { _ in
            self.createImage()
        }
        let archive = UIAlertAction(title: "保存为WebArchive", style: .default, handler: { _ in
            self.createWebArchive()
        })
        let copyUrl = UIAlertAction(title: "复制网页链接", style: .default) { _ in
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.webView.url?.absoluteString
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertC.addAction(pdf)
        alertC.addAction(image)
        alertC.addAction(archive)
        alertC.addAction(copyUrl)
        alertC.addAction(cancel)
        alertC.popoverPresentationController?.barButtonItem = UIBarButtonItem(customView: saveButton)
        self.present(alertC, animated: true, completion: nil)
    }

}

extension WebpageViewController: WKUIDelegate, WKNavigationDelegate {
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
        self.navigationItem.title = webView.title
        let scripts = ScriptManager.shared.getScripts()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for script in scripts {
                if script.isEnable {
                    webView.evaluateJavaScript(script.code) { someAny, error in
                        print(someAny as Any)
                        print(error as Any)
                    }
                }
            }
        }
    }
}
