//
//  SchoolData.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/8.
//

import UIKit
import Foundation
import HandyJSON

class LocalData: NSObject {

    static let shared = LocalData()
    var schoolNameArr : [String] = []
    var professionArr : [String] = []
    
    override init() {
       super.init()
       schoolNameArr = readSchoolData()
       professionArr = readProfessionData()
    }
    
    func readSchoolData() -> [String]{
        log.info("path:\(Bundle.main.bundlePath)")
        guard let path = Bundle.main.path(forResource: "school_data", ofType: "json") else{
            return []
        }
        do{
            let  data = try NSData.init(contentsOfFile: path) as Data
            let dicData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
            guard let schoolArr = dicData!["provs"] as? [[String:Any]] else{
                return []
            }
            
            var tempArr : [String] = []
            for dic in schoolArr {
                guard let univs = dic["univs"] as? [[String:Any]] else{
                    continue
                }
                
                for item in univs {
                    guard let name = item["name"] as? String else{
                        continue
                    }
                    tempArr.append(name)
                }
                
            }
            
            return tempArr
            
        }catch{
            log.info("read school data failed:\(error)")
        }
       
        return []
    }
    
    func searchSchooName(name:String) -> [String]{
        var tempArr : [String] = []
        for item in schoolNameArr {
            if item.contains(name) {
                tempArr.append(item)
            }
        }
        return tempArr
    }
    
    func readProfessionData() -> [String]{
        log.info("path:\(Bundle.main.bundlePath)")
        guard let path = Bundle.main.path(forResource: "profession", ofType: "json") else{
            return []
        }
        do{
            let  data = try NSData.init(contentsOfFile: path) as Data
            guard let dataArr = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String:Any]] else{
                return []
            }
          
            var tempArr : [String] = []
            for dic in dataArr {
                guard let scName = dic["sc_name"] as? String else{
                    continue
                }
                if scName.contains("/") {
                    let arr = scName.components(separatedBy: "/")
                    for str in arr {
                        tempArr.append(str)
                    }
                }else{
                    tempArr.append(scName)
                }
                
            }
            
            return tempArr
            
        }catch{
            log.info("read profession failed:\(error)")
        }
       
        return []
    }
    
    func searchProfessionName(name:String) -> [String]{
        var tempArr : [String] = []
        for item in professionArr {
            if item.contains(name) {
                tempArr.append(item)
            }
        }
        return tempArr
    }
}



class SchoolNameModel: HandyJSON{
    var id : Int = 0
    var name : String = ""
    required init(){
        
    }
    
}
