//
//  BaseRequest.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/14.
//

import UIKit
import Alamofire
import SwiftUI
import CommonCrypto
import CryptoKit


struct ResponseData{
    var code : Int
    var data : [String:Any]
    var message : String
}

open class BaseRequest: NSObject {
   static let shared  = BaseRequest()
   var dataRequest : DataRequest? = nil
   var uploadRequest :UploadRequest? = nil
   var httpHeaders : HTTPHeaders = HTTPHeaders()
   var url :String = ""
   var method :HTTPMethod = .post
   var params : Parameters? = nil
   var encoding : ParameterEncoding = JSONEncoding.default
   var uploadImageParams : [String:String]? = nil
   var uploadImage:UIImage? = nil
    public override init() {
        httpHeaders.add(name: "Content-type", value: "application/json")
    }
    
    func updateHeaders(){
        if !UserCenter.shared.token.isEmpty {
            httpHeaders.add(name: "Authorization", value: "Bearer " + UserCenter.shared.token)
        }
    }
    
   func request(urlStr: String,
                method: HTTPMethod = .get,
            parameters: Parameters? = nil,
                encoding: ParameterEncoding = JSONEncoding.default,completionHandler: @escaping (_ response: ResponseData) -> Void,failedHandler: @escaping (_ response: ResponseData) -> Void){
        let requestUrlStr = Consts.shared.domain + "/" + urlStr
        print("requestUrlStr:\(requestUrlStr), method:\(method), params:\(String(describing: parameters))")
        updateHeaders()
       dataRequest = AF.request(requestUrlStr, method: method, parameters: parameters, encoding: encoding, headers: httpHeaders).response{ response in
            print("\(response)")
            if response.response?.statusCode == 200 {
                if let dic = try? JSONSerialization.jsonObject(with: response.data ?? Data(), options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any]{
                    print("dic:\(String(describing: dic))")
                    let code = dic["code"] as? Int ?? 0
                    let data = dic["data"] as? [String:Any] ?? [:]
                    let message = dic["message"] as? String ?? ""
                    let res = ResponseData(code: code, data: data, message: message)
                    if res.code == 0 {
                        completionHandler(res)
                        log.info("requestSuc:\(requestUrlStr) response:\(dic)")
                    }else{
                        failedHandler(res)
                        if res.code == 4001{
                            //token失效
                            UserCenter.shared.LogOut()
                        }
                        log.info("requestFailed:\(requestUrlStr) response:\(dic)")
                    }
                    
                }else{
                    
                }
            }else{
                let code = response.response?.statusCode ?? 0
                let data : [String:Any] = [:]
                let message = response.error?.localizedDescription ?? ""
                let res = ResponseData(code: code, data: data, message: message)
                failedHandler(res)
                log.info("requestFailed:\(requestUrlStr) response:\(res)")
            }
           
           
        }
       
    }
    
    func cancel(){
        dataRequest?.cancel()
        uploadRequest?.cancel()
    }
  
    
    //MARK: 上传图片 -
    func uploadingImage(urlStr:String,params:[String:String],images:[UIImage],completionHandler:@escaping (_ response: ResponseData) -> Void,failedHandler: @escaping (_ response: ResponseData) -> Void){
        let requestUrlStr = Consts.shared.domain + "/" + urlStr
        print("requestUrlStr:\(requestUrlStr), method: Post")
        let headers :HTTPHeaders = [
        "Authorization": "Bearer " + UserCenter.shared.token,
        "Content-type": "multipart/form-data",
        ]
       uploadRequest = AF.upload(multipartFormData: { multipartFormData in
            for (key,value) in params {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
           for image in images {
//               let compressImage = image.resizedMB(maxLenth: 1)!
               let data = image.jpegData(compressionQuality: 0.1)!
               let fileName = data.sha256
//                   log.info("str--------\(str)")
               multipartFormData.append(data, withName: "userPhoto",fileName:fileName + ".jpeg" ,mimeType: "image/jpeg")
               
           }
           
            
        }, to: requestUrlStr,headers:headers).uploadProgress{ progress in
            log.info("fractionCompleted:\(progress.fractionCompleted)")
            log.info("totalUnitCount:\(progress.totalUnitCount)")
            log.info("completedUnitCount:\(progress.completedUnitCount)")
        }.response{ response in
            switch response.result{
            case .failure(_):
            let code = response.response?.statusCode ?? 0
            let data : [String:Any] = [:]
            let message = response.error?.errorDescription ?? ""
            let res = ResponseData(code: code, data: data, message: message)
            failedHandler(res)
            case .success(_):
            if let dic = try? JSONSerialization.jsonObject(with: response.data ?? Data(), options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any]{
                print("dic:\(String(describing: dic))")
                let code = dic["code"] as? Int ?? 0
                let data = dic["data"] as? [String:Any] ?? [:]
                let message = dic["message"] as? String ?? ""
                let res = ResponseData(code: code, data: data, message: message)
                if res.code == 0 {
                    completionHandler(res)
                }else{
                    failedHandler(res)
                }
                
              }
            }
        }
            
    }
        
    

}



