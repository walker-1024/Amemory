//
//  ScriptManager.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/10/27.
//

import Foundation
import UIKit
import CoreData

class ScriptManager {

    static let shared = ScriptManager()

    private var scripts: [ScriptModel] = []

    // 为了方便，添加一个脚本的时候会以递增方式生成 scriptId，scriptId 只会在本地使用
    private var nextScriptId: Int!

    private init() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        let fetchRequest = NSFetchRequest<ScriptEntity>(entityName: "ScriptEntity")
        guard let result = try? context.fetch(fetchRequest) else { return }
        nextScriptId = result.count + 1
        if result.count == 0 {
            add(scripts: BaseScripts)
        } else {
            for item in result {
                if item.isDelete { continue }
                let script = ScriptModel(
                    scriptId: item.scriptId ?? "",
                    title: item.title ?? "",
                    code: item.code ?? "",
                    isEnable: item.isEnable,
                    isEditable: item.isEditable,
                    auther: item.auther,
                    introduction: item.introduction
                )
                scripts.append(script)
            }
        }
    }

    private func getNextScriptId() -> Int {
        let res = nextScriptId
        nextScriptId += 1
        return res!
    }

    @discardableResult
    func refresh() -> [ScriptModel] {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return []
        }
        var scripts: [ScriptModel] = []
        let fetchRequest = NSFetchRequest<ScriptEntity>(entityName: "ScriptEntity")
        guard let result = try? context.fetch(fetchRequest) else { return [] }
        for item in result {
            if item.isDelete { continue }
            let script = ScriptModel(
                scriptId: item.scriptId ?? "",
                title: item.title ?? "",
                code: item.code ?? "",
                isEnable: item.isEnable,
                isEditable: item.isEditable,
                auther: item.auther,
                introduction: item.introduction
            )
            scripts.append(script)
        }
        self.scripts = scripts
        return scripts
    }

    func getScripts() -> [ScriptModel] {
        return scripts
    }

    func add(scripts newScripts: [ScriptModel]) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        for script in newScripts {
            let scriptId = String(getNextScriptId())
            scripts.append(ScriptModel(
                            scriptId: scriptId,
                            title: script.title,
                            code: script.code,
                            isEnable: script.isEnable,
                            isEditable: script.isEditable,
                            auther: script.auther,
                            introduction: script.introduction
            ))

            guard let item = NSEntityDescription.insertNewObject(forEntityName: "ScriptEntity", into: context) as? ScriptEntity else {
                continue
            }
            item.scriptId = scriptId
            item.title = script.title
            item.code = script.code
            item.isEnable = script.isEnable
            item.isEditable = script.isEditable
            item.auther = script.auther
            item.introduction = script.introduction
            item.isDelete = false
            try? context.save()
        }
    }

    func setScript(script theScript: ScriptModel, isEnable: Bool) {
        for i in 0..<scripts.count {
            if scripts[i].scriptId == theScript.scriptId {
                scripts[i].isEnable = isEnable
                break
            }
        }

        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        let fetchRequest = NSFetchRequest<ScriptEntity>(entityName: "ScriptEntity")
        let predicate = NSPredicate(format: "scriptId == \"\(theScript.scriptId)\"")
        fetchRequest.predicate = predicate
        guard let result = try? context.fetch(fetchRequest) else { return }
        guard result.count > 0 else { return }
        result[0].isEnable = isEnable
        try? context.save()
    }

    func modify(script theScript: ScriptModel) {
        for i in 0..<scripts.count {
            if scripts[i].scriptId == theScript.scriptId {
                scripts[i] = theScript
                break
            }
        }

        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        let fetchRequest = NSFetchRequest<ScriptEntity>(entityName: "ScriptEntity")
        let predicate = NSPredicate(format: "scriptId == \"\(theScript.scriptId)\"")
        fetchRequest.predicate = predicate
        guard let result = try? context.fetch(fetchRequest) else { return }
        guard result.count > 0 else { return }
        result[0].title = theScript.title
        result[0].code = theScript.code
        result[0].isEnable = theScript.isEnable
        result[0].isEditable = theScript.isEditable
        result[0].auther = theScript.auther
        result[0].introduction = theScript.introduction
        try? context.save()
    }

    // 采取伪删除的方式
    func delete(scriptIds deleteScriptIds: [String]) {
        scripts.removeAll { script in
            return deleteScriptIds.contains(script.scriptId)
        }

        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        let fetchRequest = NSFetchRequest<ScriptEntity>(entityName: "ScriptEntity")
        guard let result = try? context.fetch(fetchRequest) else { return }
        for item in result {
            guard let scriptId = item.scriptId else { continue }
            if deleteScriptIds.contains(scriptId) {
                item.isDelete = true
            }
        }
        try? context.save()
    }
}

// 内置脚本
private let BaseScripts = [
    ScriptModel(
        scriptId: "",
        title: "取消图片懒加载",
        code: NoLazyLoadImageScript,
        isEnable: true,
        isEditable: false,
        auther: "https://github.com/ywzhaiqi/",
        introduction: "执行此脚本可以实现无需下拉网页也能自动加载不在显示区域内的图片。"
    ),
    ScriptModel(
        scriptId: "",
        title: "完整显示公众号文章发布时间",
        code: "document.getElementById(\"publish_time\").click();",
        isEnable: false,
        isEditable: false,
        auther: "Amemory",
        introduction: """
        微信公众号文章标题下面显示的时间默认格式为"今天"、"昨天"、"一周前"、"9月3日"等。
        执行此脚本将模拟点击一次该时间标签，以将时间格式转换为形如"2021-10-24"的格式。
        """
    ),
    ScriptModel(
        scriptId: "",
        title: "屏蔽公众号文章底部推荐",
        code: "document.getElementById('js_related_container').remove();",
        isEnable: false,
        isEditable: false,
        auther: "Amemory",
        introduction: """
        部分微信公众号文章最底部有"喜欢此内容的人还喜欢"的部分。
        执行此脚本将会删去这部分内容。
        """
    )
]

// https://greasyfork.org/zh-CN/scripts/10697-no-lazy-image-load/code
let NoLazyLoadImageScript = """
// ==UserScript==
// @name         No Lazy Image load
// @namespace    https://github.com/ywzhaiqi/
// @version      1.1
// @description  取消图片的延迟加载
// @include      http*
// @grant        none
// ==/UserScript==

var lazyAttributes = [
    "zoomfile", "file", "original", "load-src", "_src", "imgsrc", "real_src", "src2", "origin-src",
    "data-lazyload", "data-lazyload-src", "data-lazy-load-src",
    "data-ks-lazyload", "data-ks-lazyload-custom",
    "data-src", "data-defer-src", "data-actualsrc",
    "data-cover", "data-original", "data-thumb", "data-imageurl",  "data-placeholder",
];

// 转为 Object
var lazyAttributesMap = {};
lazyAttributes.forEach(function(name){
    lazyAttributesMap[name] = true;
});

function noLazyNode(node) {
    any(node.attributes, function(attr) {
        if (attr.name in lazyAttributesMap) {
            var newSrc = attr.value;
            if (node.src != newSrc) {
                // console.log('%s 被替换为 %s', node.src, newSrc);
                node.src = newSrc;
            }
            return true;
        }
    });
}

function any(c, fn) {
    if (c.some) {
        return c.some(fn);
    }
    if (typeof c.length === 'number') {
        return Array.prototype.some.call(c, fn);
    }
    return Object.keys(c).some(function(k) {
        return fn(c[k], k, c);
    });
}

function map(c, fn) {
    if (c.map) {
        return c.map(fn);
    }
    if (typeof c.length === 'number') {
        return Array.prototype.map.call(c, fn);
    }
    return Object.keys(c).map(function(k) {
        return fn(c[k], k, c);
    });
}

function addMutationObserver(selector, callback) {
    var watch = document.querySelector(selector);
    if (!watch) return;

    var observer = new MutationObserver(function(mutations){
        mutations.forEach(function(m) {
            map(m.addedNodes, function(node) {
                if (node.nodeType == Node.ELEMENT_NODE) {
                    callback(node);
                }
            });
        });
    });
    observer.observe(watch, {childList: true, subtree: true});
}

function run() {
    map(document.images, noLazyNode);

    addMutationObserver('body', function(parent) {
        var images = parent.querySelectorAll('img');
        if (images) {
            map(images, noLazyNode);
        }
    });
}

run();
"""
