//
//  UserCenter.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/25.
//

import SwiftUI

class UserCenter : NSObject,ObservableObject{
    static let  shared = UserCenter()
    @Published var token : String = ""
    @Published var isLogin : Bool = false
    @Published var userInfoModel : ReCommandModel? = nil
    func setDefaultData(){
        token = readToken()
        if !token.isEmpty {
            isLogin = true
        }else{
            isLogin = false
        }
        let model = readUserInfoModel()
        if model == nil {
            requestUserInfo()
        }
    }
    
    func requestUserInfo(){
        NW.request(urlStr: "get/user/info", method: .post, parameters: nil) { response in
            let dic = response.data
            guard let model = ReCommandModel.deserialize(from: dic, designatedPath: nil) else{
                return
            }
            self.userInfoModel = model
            log.info("nickName:\(model.nickName)")
        } failedHandler: { response in
            
        }

    }
    
    func saveUserInfoModel(userInfoModel:ReCommandModel?){
        if userInfoModel == nil {
            return
        }
        
        let path = getDocumentDir().appendingPathComponent("userInfo")
        do{
            let data = try  NSKeyedArchiver.archivedData(withRootObject: userInfoModel!, requiringSecureCoding: true)
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
            let userInfoModel = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? ReCommandModel ?? nil
             return userInfoModel
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
            requestUserInfo()
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
    
}
