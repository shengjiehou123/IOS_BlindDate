//
//  Header.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/25.
//

import SwiftUI

import XCGLogger

import Alamofire

enum RefreshState{
    case normal
    case pullDown
    case pullUp
    case refresh
}

public let log = XCGLogger.default

public let screenWidth = UIScreen.main.bounds.width

public let screenHeight = UIScreen.main.bounds.height
