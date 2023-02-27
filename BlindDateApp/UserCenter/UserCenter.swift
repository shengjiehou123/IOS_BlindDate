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
    override init() {
        super.init()
        token = readToken()
        if !token.isEmpty {
            isLogin = true
        }else{
            isLogin = false
        }
    }
    func saveToken(token:String){
        if token.isEmpty {
            return
        }
        let path = getDocumentDir().appendingPathComponent("userToken")
        do{
            let data = try  NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
            try data.write(to: path)
            isLogin = true
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
