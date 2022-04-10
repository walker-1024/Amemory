//
//  VisitorManager.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/8/5.
//

import Foundation

class VisitorManager {

    static func checkVisitorAccount() {
        if let _ = UserConfigManager.shared.getValue(of: .token) { return }
        guard let email = UserConfigManager.shared.getValue(of: .visitorEmail) else {
            getVisitorAccount()
            return
        }
        guard let password = UserConfigManager.shared.getValue(of: .visitorPassword) else {
            getVisitorAccount()
            return
        }
        let paras = ["email": email, "password": password]
        let config = WebAPIConfig(subspec: "user", function: "login")
        NetworkManager.shared.request(config: config, parameters: paras).responseModel { (result: NetworkResult<BackDataWrapper<LoginBackData>>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.code == 0, let backData = res.data {
                        UserConfigManager.shared.saveValue(true, to: .visitor)
                        UserConfigManager.shared.saveValue(backData.token, to: .token)
                        NotificationCenter.default.post(name: .needRefreshProfile, object: self)
                    } else {
                        getVisitorAccount()
                    }
                case .failure(_):
                    break
                }
            }
        }
    }

    static func getVisitorAccount() {
        let config = WebAPIConfig(subspec: "user", function: "getVisitor")
        NetworkManager.shared.request(config: config, parameters: nil).responseModel { (result: NetworkResult<BackDataWrapper<GetVisitorAccountBackData>>) in
            switch result {
            case .success(let res):
                if res.code == 0, let backData = res.data {
                    UserConfigManager.shared.saveValue(true, to: .visitor)
                    UserConfigManager.shared.saveValue(backData.email, to: .visitorEmail)
                    UserConfigManager.shared.saveValue(backData.password, to: .visitorPassword)
                    UserConfigManager.shared.saveValue(backData.token, to: .token)
                    NotificationCenter.default.post(name: .needRefreshProfile, object: self)
                }
            case .failure(_):
                break
            }
        }
    }
}

fileprivate struct LoginBackData: Codable {
    var token: String
}

struct GetVisitorAccountBackData: Codable {
    var email: String
    var password: String
    var token: String
}
