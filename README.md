# Amemory

## 简介

Amemory 是一个 iOS / iPadOS 平台的工具类 App，于 2021 年 8 月 2 日上架 AppStore，主要功能是将网页快捷地保存为 PDF 文件、PNG 图片 或 Webarchive 文件。以下是在 AppStore 的介绍：

```
看到一个好的网页却担心它以后会404？遇到一篇好的文章却暂时没有时间看？
使用Amemory将网页保存为PDF、PNG图片或WebArchive文件，不再有离线和外网的障碍！
喜欢某个公众号，想要保存它的文章？Amemory帮你批量下载！

Feature:
- 可以选择将网页内容全部放在一整页PDF中，也可以自定义比例将PDF分页。
- 应用内置一些实用脚本，你也可以添加自定义的脚本，所有开启的脚本会在任何网页打开后自动执行。
```

注：Amemory 预计将于 2022 年 6 月 9 日下架。



此仓库的代码与当前线上版本存在差别，包括但不限于：

- 与后端对接的接口 ip 更改为 `127.0.0.1`
- 删除了管理员界面的相关代码
- 删除了对腾讯云 COS 的 SDK 的依赖（`pod 'QCloudCOSXML/Transfer'`）
- 删除了与腾讯云 COS 交互的相关代码
- 删除了内购模块的依赖（`pod 'SwiftyStoreKit'`）及相关代码



## 依赖

- SnapKit
- Alamofire

