//
//  AMUIViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/3/19.
//

import UIKit

class AMUIViewController: UIViewController {

    var bottomBar: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundWhite
        if let navBar = navigationController?.navigationBar {
            navBar.tintColor = .black
        }
    }

    func genBottomBar(buttons barButtons: [BottomBarButton]) {
        // iPhone 12 Pro 的 tabBar 高度是 83
        var height: CGFloat = 83

        if let tab = self.tabBarController {
            height = tab.tabBar.bounds.height
        }

        // 如果之前生成过，就把之前的移除
        if let oldBar = self.bottomBar {
            oldBar.removeFromSuperview()
            self.bottomBar = nil
        }

        let bottomBar = UIView()

        self.view.addSubview(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(height)
        }
        bottomBar.backgroundColor = UIColor.backgroundWhite

        // 一条灰线，模拟tabBar上面的那条灰线
        let line = UIView()
        bottomBar.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(1)
        }
        line.backgroundColor = UIColor.tabBarGrayLineColor

        let gap = (ScreenWidth - CGFloat(barButtons.count) * 60) / CGFloat(barButtons.count + 1)
        for i in 0..<barButtons.count {
            let button = UIButton()
            bottomBar.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.snp.makeConstraints { make in
                make.leading.equalTo(CGFloat(i + 1) * gap + CGFloat(i) * 60)
                make.top.equalTo(10)
                make.width.equalTo(60)
                make.height.equalTo(40)
            }
            button.setTitle(barButtons[i].title, for: .normal)
            button.setTitleColor(UIColor.labelColor, for: .normal)
            if barButtons[i].targetAction != nil {
                button.addTarget(self, action: barButtons[i].targetAction!, for: barButtons[i].targetControlEvents)
            }
        }

        self.bottomBar = bottomBar
    }
}

class BottomBarButton {

    var title: String = ""
    var targetAction: Selector? = nil
    var targetControlEvents: UIControl.Event = .touchUpInside
}
