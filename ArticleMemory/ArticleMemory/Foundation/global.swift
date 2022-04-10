//
//  global.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/7/4.
//

import Foundation
import UIKit

let StatusBarH = UIApplication.shared.windows.first!.windowScene!.statusBarManager!.statusBarFrame.height
var NavBarH: CGFloat {
    func getNavBarH(vc: UIViewController?) -> CGFloat {
        if let tab = vc as? UITabBarController {
            return getNavBarH(vc: tab.viewControllers?.first)
        } else if let nav = vc as? UINavigationController {
            return nav.navigationBar.bounds.height
        } else {
            return 44
        }
    }
    return getNavBarH(vc: UIApplication.shared.windows.first?.rootViewController)
}


let ScreenWidth = UIScreen.main.bounds.width
let CommonShadowButtonWidth = 350
let CommonShadowButtonHeight = 90

let TableViewCellLongPressGesMinimumPressDuration = 0.8

let StaticWebpageUrlQA = "http://amemory-about.walker-walker.top/QA/"
let StaticWebpageUrlContactUs = "http://amemory-about.walker-walker.top/contactUs/"
let StaticWebpageUrlPrivacy = "http://amemory-about.walker-walker.top/privacy/"
let StaticWebpageUrlDisclaimers = "http://amemory-about.walker-walker.top/disclaimers/"

func presentAlert(title: String, message: String? = nil, on baseViewController: UIViewController) {
    if Thread.isMainThread {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(ok)
        baseViewController.present(alert, animated: true, completion: nil)
    } else {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(ok)
            baseViewController.present(alert, animated: true, completion: nil)
        }
    }
}
