//
//  ChargeCenterViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/7/25.
//

import UIKit

class ChargeCenterViewController: AMUIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "充值中心"
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setup() {
        let commodity1 = CommodityView()
        view.addSubview(commodity1)
        commodity1.translatesAutoresizingMaskIntoConstraints = false
        commodity1.snp.makeConstraints { make in
            make.top.equalTo(20 + NavBarH + StatusBarH)
            make.height.equalTo(CommonShadowButtonHeight * 2)
            make.width.equalTo(CommonShadowButtonWidth)
            make.centerX.equalToSuperview()
        }
        commodity1.iconImage = "icon-memory-fragment".localImage
        commodity1.nameLabelText = "记忆碎片 × 2000"
        commodity1.priceLabelText = "6 CNY"
        commodity1.gesture = UITapGestureRecognizer(target: self, action: #selector(clickBuyOne))
    }

    @objc private func clickBuyOne() {
        // some code has been deleted
    }
}

fileprivate struct ChargeParas: Codable {
    var level: Int
}

fileprivate struct ChargeBackData: Codable {
    var gain: Int
    var point: Int
}
