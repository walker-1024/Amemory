//
//  NetworkManager.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/3/16.
//

import Foundation
import Alamofire

class NetworkManager {

    static let shared = NetworkManager()

    private init() { }

    func request(API: WebAPI, placeholders: [String: String]? = nil, parameters: [String: String]? = nil, headers: [String: String]? = nil) -> NetworkRequest {
        guard let url = getTruePath(API: API, providePlaceholders: placeholders) else {
            return FailNetworkRequest(.urlParameterNotEnough)
        }
        let method = API.method
        var urlRequest: URLRequest!
        if method == .get {
            if let paras = parameters {
                let paraStr = paras.compactMap({ (key, value) in
                    return "\(key)=\(value)"
                }).joined(separator: "&").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                urlRequest = URLRequest(url: URL(string: url + "?" + paraStr)!, method: method, headers: headers)
            } else {
                urlRequest = URLRequest(url: URL(string: url)!, method: method, headers: headers)
            }
        } else {
            urlRequest = URLRequest(url: URL(string: url)!, method: method, headers: headers)
            if let paraData = try? JSONEncoder().encode(parameters) {
                urlRequest.httpBody = paraData
            }
        }
        return CommonNetworkRequest(urlRequest: urlRequest)
    }

    func request(config: WebAPIConfig, placeholders: [String: String]? = nil, parameters: [String: String]? = nil, headers: [String: String]? = nil) -> NetworkRequest {
        guard let API = WebAPIMgr.shared.getAPI(in: config.subspec, for: config.function) else {
            return FailNetworkRequest(.badConfig)
        }
        return request(API: API, placeholders: placeholders, parameters: parameters, headers: headers)
    }

    func request<Paras: Codable>(API: WebAPI, placeholders: [String: String]? = nil, parameters: Paras? = nil, headers: [String: String]? = nil) -> NetworkRequest {
        guard let url = getTruePath(API: API, providePlaceholders: placeholders) else {
            return FailNetworkRequest(.urlParameterNotEnough)
        }
        let method = API.method
        var urlRequest: URLRequest!
        if method == .get {
            if let paras = parameters {
                let structMirror = Mirror(reflecting: paras).children
                let paraStr = structMirror.compactMap({ (key, value) in
                    guard let key = key else { return "" }
                    return "\(key)=\(value)"
                }).joined(separator: "&")
                urlRequest = URLRequest(url: URL(string: url + "?" + paraStr)!, method: method, headers: headers)
            } else {
                urlRequest = URLRequest(url: URL(string: url)!, method: method, headers: headers)
            }
        } else {
            urlRequest = URLRequest(url: URL(string: url)!, method: method, headers: headers)
            if let paraData = try? JSONEncoder().encode(parameters) {
                urlRequest.httpBody = paraData
            }
        }
        return CommonNetworkRequest(urlRequest: urlRequest)
    }

    func request<Paras: Codable>(config: WebAPIConfig, placeholders: [String: String]? = nil, parameters: Paras? = nil, headers: [String: String]? = nil) -> NetworkRequest {
        guard let API = WebAPIMgr.shared.getAPI(in: config.subspec, for: config.function) else {
            return FailNetworkRequest(.badConfig)
        }
        return request(API: API, placeholders: placeholders, parameters: parameters, headers: headers)
    }

    // 故意把传的类型分为了 UploadData 和 UploadFile，因为文件的 fileName 不能设 nil，否则会请求失败
    func upload<Model: Codable>(API: WebAPI, parameters: [UploadData]? = nil, files: [UploadFile]? = nil, headers: [String: String]? = nil, completion: @escaping (NetworkResult<Model>) -> Void) {
        let urlRequest = URLRequest(url: URL(string: API.path)!, method: API.method, headers: headers)
        AF.upload(multipartFormData: { multiPart in
            if let params = parameters {
                for para in params {
                    multiPart.append(para.data, withName: para.key)
                }
            }
            if let files = files {
                for file in files {
                    multiPart.append(file.data, withName: file.key, fileName: file.fileName, mimeType: file.mimeType)
                }
            }
        }, with: urlRequest).responseData { response in
            switch response.result {
            case .success(let data):
                if let model = try? JSONDecoder().decode(Model.self, from: data) {
                    completion(.success(model))
                } else {
                    completion(.failure(.decodeError))
                }
            case .failure(_):
                completion(.failure(.requestFail))
            }
        }
    }

    func upload<Model: Codable>(config: WebAPIConfig, parameters: [UploadData]? = nil, files: [UploadFile]? = nil, headers: [String: String]? = nil, completion: @escaping (NetworkResult<Model>) -> Void) {
        guard let API = WebAPIMgr.shared.getAPI(in: config.subspec, for: config.function) else {
            completion(.failure(.badConfig))
            return
        }
        upload(API: API, parameters: parameters, files: files, headers: headers, completion: completion)
    }

    // 获取填充了 path 中所需字段后的 path
    private func getTruePath(API: WebAPI, providePlaceholders: [String: String]?) -> String? {
        guard var needPlaceholders = API.placeholders, needPlaceholders.count > 0 else { return API.path }
        guard let providePlaceholders = providePlaceholders, providePlaceholders.count > 0 else { return nil }

        var output = API.path
        for (key, value) in providePlaceholders {
            let theKey = "{\(key)}"
            if needPlaceholders.contains(theKey) {
                output = output.replacingOccurrences(of: theKey, with: value)
                needPlaceholders.removeAll(where: { $0 == theKey })
            }
        }

        if needPlaceholders.count > 0 { return nil }
        return output
    }
}

extension URLRequest {
    init(url: URL, method: HTTPMethod, headers: [String: String]? = nil) {
        self.init(url: url)
        self.httpMethod = method.rawValue
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserConfigManager.shared.getValue(of: .token) {
            self.setValue(token, forHTTPHeaderField: "Authorization")
        }
        if let headers = headers {
            for (key, value) in headers {
                self.setValue(value, forHTTPHeaderField: key)
            }
        }
    }
}

struct UploadData: Codable {
    var key: String
    var data: Data
}

struct UploadFile: Codable {
    var key: String
    var data: Data
    // 注意，如果是一个文件，upload 时候文件的 fileName 不能设 nil，否则会请求失败，报错如下
    // Alamofire.AFError.ResponseSerializationFailureReason.inputDataNilOrZeroLength)
    var fileName: String
    var mimeType: String?
}
