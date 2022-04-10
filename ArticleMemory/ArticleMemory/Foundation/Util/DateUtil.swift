//
//  DateUtil.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/6/3.
//

import Foundation

extension Date {

    var formatString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
}
