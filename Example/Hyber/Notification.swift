//
//  Notification.swift
//  Hyber
//
//  Created by Taras Markevych on 3/23/17.
//  Copyright © 2017 Incuube. All rights reserved.
//

import UIKit

//

import UIKit

internal let UILayoutPriorityNotificationPadding: Float = 999

internal struct NotificationName {
    static let titleFont = UIFont.boldSystemFont(ofSize: 14)
    static let subtitleFont = UIFont.systemFont(ofSize: 13)
    
    static let animationDuration: TimeInterval = 0.3 // second(s)
    static let exhibitionDuration: TimeInterval = 5.0 // second(s)
    
}

internal struct NotificationLayout {
    static let height: CGFloat = 64.0
    static var width: CGFloat { return UIScreen.main.bounds.size.width }
    
    
    static var labelMessageHeight: CGFloat = 35
    static var dragViewHeight: CGFloat = 3
    
    
    
    static let iconSize = CGSize(width: 36, height: 36)
    
    static let labelPadding: CGFloat = 45
    
    static let accessoryViewTrailing: CGFloat = 15
}

