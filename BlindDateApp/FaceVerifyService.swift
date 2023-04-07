//
//  FaceVerifyService.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/4/7.
//

import UIKit

extension NSObject{
    func topViewController(baseVC: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController) -> UIViewController? {
       
       if let nav = baseVC as? UINavigationController {
           return topViewController(baseVC: nav.visibleViewController)
       }
       if let tab = baseVC as? UITabBarController {
           if let selected = tab.selectedViewController {
               return topViewController(baseVC: selected)
           }
       }
       if let presented = baseVC?.presentedViewController {
           return topViewController(baseVC: presented)
       }
       return baseVC
   }
}

class FaceVerifyService: NSObject {

    static let shared = FaceVerifyService()
    
    override init() {
        AliyunSdk.init()
    }
    
    func verify(){
        let extParam = ["currentCtr":self.topViewController()]
        AliyunIdentityManager.sharedInstance().verify(with: "", extParams: extParam as [AnyHashable : Any]) { zimResponse in

            
        }
    }
    
}
