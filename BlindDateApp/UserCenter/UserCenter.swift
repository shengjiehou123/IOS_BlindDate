//
//  UserCenter.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/25.
//

import SwiftUI

class UserCenter : NSObject{
    static let  shared = UserCenter()
    
    func saveToken(token:String){
        if token.isEmpty {
            return
        }
        let path = getDocumentDir().appendingPathComponent("userToken")
        do{
            let data = try ? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
            data.write(to: path)
        } catch (err:Error) {
            log.info(
        }
       
    }
    
    func readToken() ->String{
        
    }
    
    func getDocumentDir() -> URL{
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }
    
}
