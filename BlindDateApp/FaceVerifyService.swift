//
//  FaceVerifyService.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/4/7.
//

import UIKit
import AliyunIdentityManager

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

class FaceVerifyService:NSObject, ObservableObject {

    static let shared = FaceVerifyService()
    
    func initAliyunSDK(){
        AliyunSdk.init()
    }
    
    func requestVerifyToken(certificateName:String,certificateNumber:String){
        guard let metaInfo = AliyunIdentityManager.getMetaInfo() else{
            return
        }
        guard let metaData = try? JSONSerialization.data(withJSONObject: metaInfo) else{
            return
        }
        let metaInfoStr = String(data: metaData, encoding: String.Encoding.utf8)!
        let param = ["certificateName":certificateName,"certificateNumber":certificateNumber,"metaInfo":metaInfoStr] as [String : Any]
        NW.request(urlStr: "get/verification/token",method: .post,parameters: param) { response in
            let dic = response.data
            guard let verificationToken = dic["verificationToken"] as? String else{
                return
            }
            log.info("requestVerifyToken Suc")
            self.verify(verificationToken: verificationToken)
        } failedHandler: { response in
            log.info("requestVerifyToken failed")
        }

    }
    
    func verify(verificationToken:String){
        let extParam = ["currentCtr":self.topViewController()]
        AliyunIdentityManager.sharedInstance().verify(with: verificationToken, extParams: extParam as [AnyHashable : Any]) { zimResponse in
            guard let code = zimResponse?.code else{
                return
            }
            switch code{
            case .ZIMResponseSuccess:
                //采集成功并且服务端成功(人脸比对成功，或者证件宝服务端OCR/质量检测成功)[zim不会弹框处理]
                break
            case .ZIMInternalError:
                //用户被动退出(极简核身没有取到协议、toyger启动失败、协议解析失败)[zim不会弹框处理]
                break
            case .ZIMInterrupt:
                ///用户主动退出(无相机权限、超时、用户取消)[zim会弹框处理]
                ///
                break
            case .ZIMNetworkfail:
                //网络失败(标准zim流程，请求协议错误)[zim不会弹框处理
                break
            case .ZIMTIMEError:
                ////设备时间设置不对
                break
            case .ZIMResponseFail:
                //服务端validate失败(人脸比对失败或者证件宝OCR/质量检测失败)[zim不会弹框处理]
                break
            @unknown default:
                break
          
            }
            
//            zimResponse?.faceData
//            zimResponse.imageContent
//            zimResponse?.countryData
//            guard let dicData = try? JSONSerialization.jsonObject(with: zimResponse?.countryData ?? Data()) else{
//                return
//            }
            log.info("verify Suc")
            log.info("faceData: \(String(describing: zimResponse?.faceData)) imageContent:\(String(describing: zimResponse?.imageContent!))")
            
     
            /**
             ZIMResponseSuccess  = 1000,     //采集成功并且服务端成功(人脸比对成功，或者证件宝服务端OCR/质量检测成功)[zim不会弹框处理]
             ZIMInternalError    = 1001,     //用户被动退出(极简核身没有取到协议、toyger启动失败、协议解析失败)[zim不会弹框处理]
             ZIMInterrupt        = 1003,     //用户主动退出(无相机权限、超时、用户取消)[zim会弹框处理]
             ZIMNetworkfail      = 2002,     //网络失败(标准zim流程，请求协议错误)[zim不会弹框处理]
             ZIMTIMEError        = 2003,    //设备时间设置不对
             ZIMResponseFail     = 2006     //服务端validate失败(人脸比对失败或者证件宝OCR/质量检测失败)[zim不会弹框处理]
             */
            
        }
    }
    
}
