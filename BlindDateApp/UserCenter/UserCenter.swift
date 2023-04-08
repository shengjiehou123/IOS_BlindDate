//
//  UserCenter.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/25.
//

import SwiftUI
import ImSDK_Plus_Swift

class UserCenter :ObservableObject{
    static let  shared = UserCenter()
    @Published var token : String = ""
    @Published var isLogin : Bool = false
    @Published var userInfoModel : ReCommandModel? = nil
    var userSig : String = ""
    func setDefaultData(){
        token = readToken()
        if !token.isEmpty {
            isLogin = true
        }else{
            isLogin = false
        }
        let model = readUserInfoModel()
        self.userInfoModel = model
        if model == nil {
            requestUserInfo(needUserSig: true)
        }else{
            requestChatUserSig()
        }
    }
    
    func loginTIM(){
        if let model =  UserCenter.shared.userInfoModel{
            let config = V2TIMSDKConfig()
            config.logLevel = .V2TIM_LOG_INFO
            V2TIMManager.shared.addIMSDKListener(listener: MessageModel.shared)
           _ = V2TIMManager.shared.initSDK(sdkAppID: 1400794630, config: config)
            let userId = "\(model.id)"
            V2TIMManager.shared.login(userID: userId, userSig: userSig) {
                log.info("TIM Chat login suc")
            } fail: { code, desc in
                log.info("ailure, code:\(code), desc:\(String(describing: desc))")
            }

        }else{
            requestUserInfo(needUserSig: true)
        }
       
    }
    
    func requestChatUserSig(){
        if !UserCenter.shared.isLogin {
            return
        }
        NW.request(urlStr: "chat/user/sig", method: .post, parameters: nil) { response in
            guard let sig = response.data["sig"] as? String else{
                return
            }
            self.userSig = sig
            self.loginTIM()
        } failedHandler: { response in
            
        }
    }
    
    
    func requestUserInfo(needUserSig:Bool){
        if !UserCenter.shared.isLogin {
            return
        }
        NW.request(urlStr: "get/user/info", method: .post, parameters: nil) { response in
            let dic = response.data
            guard let model = ReCommandModel.deserialize(from: dic, designatedPath: nil) else{
                return
            }
            self.userInfoModel = model
            self.saveUserInfoModel(userInfoModel: model)
            if needUserSig {
                self.requestChatUserSig()
            }
            log.info("nickName:\(model.nickName)")
        } failedHandler: { response in
            
        }

    }
    
    func requestUploadPhoto(scenes:String){
        
    }
    
    func saveUserInfoModel(userInfoModel:ReCommandModel?){
        if userInfoModel == nil {
            return
        }
        
        let path = getDocumentDir().appendingPathComponent("userInfo")
        do{
            guard let json = userInfoModel?.toJSON() else{
                return
            }
            let data = try  NSKeyedArchiver.archivedData(withRootObject: json, requiringSecureCoding: true)
            try data.write(to: path)
            self.userInfoModel = userInfoModel!
        } catch{
            log.info("\(error)")
        }
    }
    
    func readUserInfoModel() ->ReCommandModel?{
        let path = getDocumentDir().appendingPathComponent("userInfo")
        let exist = FileManager.default.fileExists(atPath: path.path)
        if !exist {
            return nil
        }
        
        do{
            let data = try Data.init(contentsOf: path)
            guard let json = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String:Any] else{
                return nil
            }
            guard let model =  ReCommandModel.deserialize(from: json, designatedPath: nil) else{
            
                return nil
            }
             return model
        }catch{
            log.info("\(error)")
        }
       return nil
    }
    
    
    
    func saveToken(token:String){
        if token.isEmpty {
            return
        }
        let path = getDocumentDir().appendingPathComponent("userToken")
        do{
            let data = try  NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
            try data.write(to: path)
            self.token = token
            isLogin = true
            requestUserInfo(needUserSig: true)
        } catch{
            log.info("\(error)")
        }
       
    }
    
    func readToken() ->String{
        let path = getDocumentDir().appendingPathComponent("userToken")
        let exist = FileManager.default.fileExists(atPath: path.path)
        if !exist {
            return ""
        }
        
        do{
            let data = try Data.init(contentsOf: path)
            let token = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? String ?? ""
             return token
        }catch{
            log.info("\(error)")
        }
       return ""
    }
    
    func getDocumentDir() -> URL{
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }
    
    func clearLocalInfo(){
        let tokenPath = getDocumentDir().appendingPathComponent("userToken").path
        if FileManager.default.fileExists(atPath: tokenPath) {
           try? FileManager.default.removeItem(atPath: tokenPath)
        }
       
        
        let userInfoPath = getDocumentDir().appendingPathComponent("userInfo").path
        if FileManager.default.fileExists(atPath: userInfoPath){
            try? FileManager.default.removeItem(atPath: userInfoPath)
        }
        isLogin = false
        token = ""
        userInfoModel = nil
    }
    
    func LogOut(){
        clearLocalInfo()
    }
}
