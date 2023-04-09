//
//  BaseModel.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/27.
//

import UIKit
import SwiftUI

class BaseModel: MyComputedProperty {

  @Published private var _lastUpdateTime: Date = Date()
   /// 通知更新
   public func notifyUpdate() {
       _lastUpdateTime = Date()
   }

}

class MyComputedProperty:NSObject,ObservableObject{
    @Published var showLoading:Bool = false
    @Published var loadingBgColor:Color = .clear
    @Published var showRefreshView : Bool = false
    @Published var errorMsg : String = ""
    @Published var pullDown : Bool = false
    @Published var footerRefreshing: Bool = false
    @Published var loadMore : Bool = false
    @Published var noData : Bool = false
    @Published var showToast : Bool = false
    @Published var toastMsg : String = ""
    
}
