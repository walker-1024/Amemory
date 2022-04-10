//
//  NotificationUtil.swift
//  ArticleMemory
//
//  Created by 刘菁楷 on 2021/8/28.
//

import Foundation

extension Notification.Name {

    static var downloadSuccess: Self {
        return Notification.Name("AMNotification_TaskDownloadSuccess")
    }

    static var needRefreshProfile: Self {
        return Notification.Name("AMNotification_NeedRefreshProfile")
    }
}
