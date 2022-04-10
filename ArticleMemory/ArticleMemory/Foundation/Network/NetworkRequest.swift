//
//  NetworkRequest.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/7/4.
//

import Foundation
import Alamofire

protocol NetworkRequest {
    func responseDict(completion: @escaping (NetworkResult<[String: Any]>) -> Void)
    func responseString(completion: @escaping (NetworkResult<String>) -> Void)
    func responseData(completion: @escaping (NetworkResult<Data>) -> Void)
    func responseModel<Model: Codable>(completion: @escaping (NetworkResult<Model>) -> Void)
}

class CommonNetworkRequest: NetworkRequest {

    var urlRequest: URLRequest!

    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }

    func responseDict(completion: @escaping (NetworkResult<[String: Any]>) -> Void) {
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil, let data = data {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
                    completion(.failure(.decodeError))
                    return
                }
                guard let dict = json as? [String: Any] else {
                    completion(.failure(.decodeError))
                    return
                }
                completion(.success(dict))
            } else {
                completion(.failure(.requestFail))
            }
        }
        dataTask.resume()
    }

    func responseString(completion: @escaping (NetworkResult<String>) -> Void) {
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil, let data = data {
                if let str = String(data: data, encoding: .utf8) {
                    completion(.success(str))
                } else {
                    completion(.failure(.decodeError))
                }
            } else {
                completion(.failure(.requestFail))
            }
        }
        dataTask.resume()
    }

    func responseData(completion: @escaping (NetworkResult<Data>) -> Void) {
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil, let data = data {
                completion(.success(data))
            } else {
                completion(.failure(.requestFail))
            }
        }
        dataTask.resume()
    }

    func responseModel<Model: Codable>(completion: @escaping (NetworkResult<Model>) -> Void) {
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil, let data = data {
                if let model = try? JSONDecoder().decode(Model.self, from: data) {
                    completion(.success(model))
                } else {
                    completion(.failure(.decodeError))
                }
            } else {
                completion(.failure(.requestFail))
            }
        }
        dataTask.resume()
    }

}

class FailNetworkRequest: NetworkRequest {

    var networkError: NetworkError!

    init(_ networkError: NetworkError) {
        self.networkError = networkError
    }

    func responseDict(completion: @escaping (NetworkResult<[String : Any]>) -> Void) {
        completion(.failure(networkError))
    }

    func responseString(completion: @escaping (NetworkResult<String>) -> Void) {
        completion(.failure(networkError))
    }

    func responseData(completion: @escaping (NetworkResult<Data>) -> Void) {
        completion(.failure(networkError))
    }

    func responseModel<Model: Codable>(completion: @escaping (NetworkResult<Model>) -> Void) {
        completion(.failure(networkError))
    }
}
