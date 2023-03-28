//
//  Header.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/25.
//

import SwiftUI

import XCGLogger

import Alamofire

import Introspect

enum RefreshState{
    case normal
    case pullDown
    case pullUp
    case refresh
}

public let log = XCGLogger.default

public let screenWidth = UIScreen.main.bounds.width

public let screenHeight = UIScreen.main.bounds.height

public let keyWindow = UIApplication.shared.connectedScenes
                        .map({ $0 as? UIWindowScene })
                        .compactMap({ $0 })
                        .first?.windows.first

public let kSafeTop = keyWindow?.safeAreaInsets.top ?? 0

public let kSafeBottom = keyWindow?.safeAreaInsets.bottom ?? 0

public let myAppRootVC : UIViewController? = keyWindow?.rootViewController


public let btnLRLineGradient : LinearGradient = .linearGradient(Gradient(colors: [Color.colorWithHexString(hex: "#F97676"),Color.colorWithHexString(hex: "#F6286F")]),startPoint: .leading,endPoint: .trailing)

public let textFieldAccentColor = Color.colorWithHexString(hex: "#F6286F")
                                                        
                                                    
                                                


//MARK: Notification

public let kNotiChatToUserId = "kChatToUserId"
                                                        
public let kNotiPushUserIntroduction = "kNotiPushUserIntroduction"

public let kNotiCreateCircle = "kNotiCreateCircle"
