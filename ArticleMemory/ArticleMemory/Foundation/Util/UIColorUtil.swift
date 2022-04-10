//
//  UIColorUtil.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/3/19.
//

import Foundation
import UIKit

extension UIColor {

    public convenience init(red: UInt8, green: UInt8, blue: UInt8) {
        self.init(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
    }

    static var backgroundWhite: UIColor {
        return UIColor(red: 247, green: 247, blue: 247)
    }

    static var tintGreen: UIColor {
        return UIColor(red: 141, green: 248, blue: 159)
    }

    static var labelColor: UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
    }

    static var secondaryLabelColor: UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }

    static var thirdLabelColor: UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }

    static var shadowButtonTitleColor: UIColor {
        return UIColor.secondaryLabelColor
    }

    // HomeVC - Begin
    static var homeShadowButtonTitleColorDisable: UIColor {
        return UIColor.secondaryLabelColor
    }

    static var homeShadowButtonTitleColor: UIColor {
        return UIColor(red: 0, green: 122, blue: 255)
    }
    // HomeVC - End

    // 用于模拟tabBar上方那条灰线
    static var tabBarGrayLineColor: UIColor {
        return UIColor(red: 227, green: 227, blue: 227)
    }

    // 圆形进度条的灰色
    static var circleProgressGrayColor: UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
    }

    // LoginVC - Begin
    static var textFieldTextColor: UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    }

    static var textFieldPlaceholderFontColor: UIColor {
        return UIColor(red: 201, green: 201, blue: 201)
    }
    // LoginVC - End

    // Script - Begin
    static var scriptTextFieldTextColor: UIColor {
        return UIColor.labelColor
    }

    static var scriptTextFieldTextHintColor: UIColor {
        return UIColor.secondaryLabelColor
    }

    static var scriptTextFieldBorderColor: UIColor {
        return UIColor.thirdLabelColor
    }

    static var scriptDescriptionVCMaskColor: UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    // Script - End

    // PdfPageSplitSettingVC - Begin
    static var settingVCTextFieldTextColor: UIColor {
        return UIColor.labelColor
    }

    static var settingVCTextFieldBorderColor: UIColor {
        return UIColor.thirdLabelColor
    }
    // PdfPageSplitSettingVC - End
}
