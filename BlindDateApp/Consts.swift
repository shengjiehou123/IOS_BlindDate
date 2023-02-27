
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
    
    public var domain : String{
        switch env {
        case .dev:
            return "http://127.0.0.1:8001/api/v1"
        case .release:
            return ""
       }
    }
}




