//
//  WebAPI.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/3/16.
//

import Foundation
import Alamofire

struct WebAPI {
    var path: String
    var method: HTTPMethod
    var placeholders: [String]?
    var parameter: [String]?
}

/// 本地读取API的路径配置
///
/// 将依据该配置文件从WebAPIs.plist里面读取API
struct WebAPIConfig {
    /// 本地读取的子空间
    ///
    /// 可以认为是网络请求的命名空间
    var subspec: String
    /// 本地读取的API名称
    ///
    /// 可以认为是网络请求的名字
    var function: String
}

class WebAPIMgr {

    static let shared = WebAPIMgr()

    private init() { }

    // the domain has been modified
    private let domain = "http://127.0.0.1:8422"

    func getAPI(in subspec: String, for function: String) -> WebAPI? {

        guard let APIs = PlistReader.shared.getDict(from: "WebAPIs") else { return nil }
        guard let subspecAPIs = APIs[subspec] as? NSDictionary else { return nil }
        guard let rawAPI = subspecAPIs[function] as? NSDictionary else { return nil }

        guard let path = rawAPI["path"] as? String else { return nil }
        guard let method = rawAPI["method"] as? String else { return nil }
        let parameter = rawAPI["parameter"] as? [String]
        let placeholders = path.regexFind(with: "\\{[^\\}]+\\}")

        return WebAPI(path: domain + path, method: HTTPMethod(rawValue: method), placeholders: placeholders, parameter: parameter)
    }

}
