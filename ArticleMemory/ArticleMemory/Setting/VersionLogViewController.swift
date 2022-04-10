//
//  VersionLogViewController.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/10/12.
//

import UIKit

class VersionLogViewController: AMUIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "版本日志"
        let textView = UITextView()
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        textView.backgroundColor = .clear
        textView.textColor = .black
        textView.isEditable = false
        textView.isSelectable = false
        textView.text = """
        Ver 2.0.3 -- 2022-04-11
        1：由于开发者账号将于六月份到期，且之后可能也没有太多时间做个人项目了，所以此版本应该是Amemory在AppStore的最终版本，且会在2022年6月9日之后下架。
        2：部分公众号的文章已于2022年4月1日00:00停止更新。已存在的文章开放自由下载，且将在一个暂未知的时间关闭。
        3：Amemory的代码在经过稍微的整理和删改后，已于2022年4月10日在Github开源：https://github.com/walker-1024/Amemory
        4：感谢所有Amemory用户的支持，离别是为了再次相遇，我们后会有期！


        Ver 2.0.2 -- 2021-12-25
        1：修复在iOS15设备上浏览图片文件或Webarchive文件时，导航栏变透明的问题。
        Ver 2.0.1 -- 2021-12-14
        1：PDF分页策略新增"按比例分页"，可自定义PDF页面的宽高比。
        2：使用 v2 接口与后端对接。
        Ver 1.4.2 -- 仅内测，未发布
        1：分享文件时，文件名自动改为文章标题名。
        2：允许在多选之后同时分享多个文件。
        3：修复已知小问题。
        Ver 1.4.1 -- 2021-12-06
        1：支持设置"PDF分页策略"。
        2：增加了"网页导航栏毛玻璃效果"的开关。
        3：设置界面UI更改。
        Ver 1.4.0 -- 2021-12-05
        1：支持将网页保存为PNG图片。
        2：修复已知问题。
        Ver 1.3.0 -- 2021-12-04
        1：解决了"对于非常长的网页，生成PDF时会被自动分页"的问题。在新版中，生成PDF时如果发现被分页，则会自动将其拼接为一页。
        2：新增一个内置脚本，且所有脚本代码均允许查看。
        3：修复已知小问题。
        Ver 1.2.0 -- 2021-12-01
        1：允许添加自定义的脚本，所有开启的脚本会在任何网页打开后自动执行。
        2：与后端对接的接口略加修改。
        Ver 1.1.6 -- 2021-11-01
        1：修复首页输入包含中文的链接后无法打开网页的bug。
        2：首页"打开网页"按钮颜色会随是否有输入的内容而改变。
        Ver 1.1.5 -- 2021-10-29
        1：开放"脚本管理"，支持用户自行选择是否开启内置的脚本，后续也将允许用户添加自定义的脚本。
        2：用户头像将自动上传至服务器，实现在不同设备间同步。
        3：更改了部分UI细节。
        4：优化账号登录退出的相关逻辑。
        Ver 1.1.4 -- 2021-10-13
        1：实现打开网页后无需手动下滑即可加载下面的图片。
        2：增加"版本日志"。
        Ver 1.1.3 -- 2021-08-30
        1：正在下载的文件也会显示在"下载文件"列表，且封面显示为一张动图。
        2：更改部分UI细节。
        Ver 1.1.2 -- 2021-08-09
        1：修复在登录个人账号又退出后，之前的游客信息丢失的问题。
        2：修复iPad上分享文件时的crash。
        Ver 1.1.1 -- 2021-08-02
        1：增加游客模式的相关逻辑，未登录时即为游客模式。
        2：发布审核通过。
        Ver 1.1.0 -- 2021-08-02
        1：发布审核未通过，原因为"未登录时不能体验全部功能"。
        """
        textView.contentOffset = CGPoint(x: 0, y: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
