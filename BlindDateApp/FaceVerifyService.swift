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

class FaceVerifyService:BaseModel {

    
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
        self.showLoading = true
        self.loadingBgColor = .clear
        self.showToast = false
        NW.request(urlStr: "get/verification/token",method: .post,parameters: param) { response in
            let dic = response.data
            guard let verificationToken = dic["verificationToken"] as? String else{
                return
            }
            log.info("requestVerifyToken Suc")
            if verificationToken.count == 0{
                self.showLoading = false
                self.showToast = true
                self.toastMsg = "获取verificationToken失败"
                return
            }
            self.requestVerifyFace(verificationToken: verificationToken)
        } failedHandler: { response in
            log.info("requestVerifyToken failed")
            self.showLoading = false
            self.showToast = true
            self.toastMsg = response.message
        }

    }
    
    func requestVerifyFace(verificationToken:String){
        let extParam = ["currentCtr":self.topViewController()]
        AliyunIdentityManager.sharedInstance().verify(with: verificationToken, extParams: extParam as [AnyHashable : Any]) { zimResponse in
            self.showLoading = false
            guard let code = zimResponse?.code else{
                return
            }
            switch code{
            case .ZIMResponseSuccess:
                //采集成功并且服务端成功(人脸比对成功，或者证件宝服务端OCR/质量检测成功)[zim不会弹框处理]
                self.showLoading = true
                if let imageContent = zimResponse?.imageContent as NSData?{
                    self.requestIdVerify(data: imageContent)
                }
                break
            case .ZIMInternalError:
                //用户被动退出(极简核身没有取到协议、toyger启动失败、协议解析失败)[zim不会弹框处理]
                self.showToast = true
                self.toastMsg = "内部错误"
                break
            case .ZIMInterrupt:
                ///用户主动退出(无相机权限、超时、用户取消)[zim会弹框处理]
                break
            case .ZIMNetworkfail:
                //网络失败(标准zim流程，请求协议错误)[zim不会弹框处理
                self.showToast = true
                self.toastMsg = "网络请求失败，请检查网络"
                break
            case .ZIMTIMEError:
                ////设备时间设置不对
                self.showToast = true
                self.toastMsg = "设备时间设置不对"
                break
            case .ZIMResponseFail:
                //服务端validate失败(人脸比对失败或者证件宝OCR/质量检测失败)[zim不会弹框处理]
                self.showToast = true
                self.toastMsg = "人脸比对失败,请检查姓名或者身份账号是否填写错误"
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
//            log.info("faceData: \(String(describing: zimResponse?.faceData)) imageContent:\(String(describing: zimResponse?.imageContent!))")
//            
     
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
    
    func requestIdVerify(data : NSData){
        let param = ["scenes":"verify"]
        guard let imageData = data as Data? else{
            return
        }
        let image = UIImage(data: imageData)!
       
        NW.uploadingImage(urlStr: "id/verified", params: param, images: [image]) { response in
            self.showLoading = false
            self.showToast = true
            self.toastMsg = "认证成功"
        } failedHandler: { response in
            self.showLoading = false
            self.showToast = true
            self.toastMsg = response.message
        }

    }
    
}
