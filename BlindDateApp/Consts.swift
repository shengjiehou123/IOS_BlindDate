
import Foundation
import UIKit
import SwiftUI

class ComputedProperty:ObservableObject{
   @Published var showLoading : Bool = false
   @Published var loadingBgColor : Color = .clear
   @Published var showToast : Bool = false
   @Published var toastMsg : String = ""
}

public let NW = BaseRequest.shared

enum NetWorkEnv {
    case dev
    case release
}

class Consts: NSObject {
    static let shared = Consts()
    
    public let env = NetWorkEnv.dev
    
    public let imageHost = "https://blinddate-1257858019.cos.ap-beijing.myqcloud.com"
    
    public var domain : String{
        switch env {
        case .dev:
            return "http://test-blinddate.natapp1.cc/api/v1"
        case .release:
            return ""
       }
    }
}




