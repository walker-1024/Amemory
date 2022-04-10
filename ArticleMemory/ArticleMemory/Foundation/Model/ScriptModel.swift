//
//  ScriptModel.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/10/13.
//

import Foundation

struct ScriptModel: Codable {
    var scriptId: String // 唯一标识符，在本地为数字字符串，目前是在添加到数据库时才会生成
    var title: String // 脚本标题
    var code: String // 脚本的js代码
    var isEnable: Bool // 是否启用
    var isEditable: Bool // 是否可以编辑，用户自己添加的脚本可以编辑，导入的脚本不可编辑
    var auther: String? // 脚本的作者
    var introduction: String? // 脚本的简介
}
