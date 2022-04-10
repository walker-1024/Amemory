//
//  UserConfigManager.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/11/30.
//

import Foundation

class UserConfigManager {

    static let shared = UserConfigManager()

    private let ud = UserDefaults()

    private init() { }

    enum UserConfig: String {
        case token = "token"
        case email = "email"
        case password = "password"
        case username = "username"
        case visitor = "visitor"
        case visitorEmail = "visitor-email"
        case visitorPassword = "visitor-password"
        case parallelDownloadNum = "parallelDownloadNum"
        case webVCNavBarBlur = "webVCNavBarBlur"
        case pdfPageSplit = "pdfPageSplit" // -1 表示不分页；-2 表示自动分页；-4表示按比例分页，宽高值在下面两个字段里
        case pdfPageSplitWidth = "pdfPageSplitWidth"
        case pdfPageSplitHeight = "pdfPageSplitHeight"
        case placeholder
    }

    func getValue(of config: UserConfig) -> String? {
        return ud.string(forKey: config.rawValue)
    }

    func getIntValue(of config: UserConfig) -> Int {
        let value = ud.integer(forKey: config.rawValue)
        if value != 0 { return value }
        // 默认值
        switch config {
        case .parallelDownloadNum:
            return 5
        case .pdfPageSplit:
            return -1
        default:
            return 0
        }
    }

    func getFloatValue(of config: UserConfig) -> Float {
        let value = ud.float(forKey: config.rawValue)
        if value != 0 { return value }
        // 默认值
        switch config {
        case .pdfPageSplitWidth:
            return 210
        case .pdfPageSplitHeight:
            return 297
        default:
            return 0
        }
    }

    func getBoolValue(of config: UserConfig) -> Bool {
        return ud.bool(forKey: config.rawValue)
    }

    func saveValue(_ value: Any, to config: UserConfig) {
        ud.setValue(value, forKey: config.rawValue)
    }

    func removeValue(of config: UserConfig) {
        ud.removeObject(forKey: config.rawValue)
    }

    func canFreeDownload() -> Bool {
        return true
    }
}
