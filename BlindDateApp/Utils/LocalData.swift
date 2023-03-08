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
    var addressArr : [AddressModel] = []
    
    override init() {
       super.init()
       schoolNameArr = readSchoolData()
       professionArr = readProfessionData()
       addressArr = readProvinceAndCityData()
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
    
    func readProvinceAndCityData() -> [AddressModel]{
        guard let provincePath = Bundle.main.path(forResource: "province", ofType: "json") else{
            return []
        }
       
        guard let cityPath =  Bundle.main.path(forResource: "city", ofType: "json") else{
            return []
        }
        
        guard let areaPath = Bundle.main.path(forResource: "area", ofType: "json") else{
            return []
        }
        
        do{
            let  provinceData = try NSData.init(contentsOfFile: provincePath) as Data
            guard let provinceArr = try? JSONSerialization.jsonObject(with: provinceData, options: .mutableContainers) as? [[String:Any]] else{
                return []
            }
            let  cityData = try NSData.init(contentsOfFile: cityPath) as Data
            guard let cityDic = try? JSONSerialization.jsonObject(with: cityData, options: .mutableContainers) as? [String:Any] else{
                return []
            }
            let  areaData = try NSData.init(contentsOfFile: areaPath) as Data
            guard let areaDic = try? JSONSerialization.jsonObject(with: areaData, options: .mutableContainers) as? [String:Any] else{
                return []
            }
            var tempProvinceArr : [AddressModel] = []
            for dic in provinceArr {
                guard let model = AddressModel.deserialize(from: dic, designatedPath: nil) else{
                    continue
                }
                guard let cityArr = cityDic["\(model.id)"] as? [[String:Any]] else{
                    continue
                }
                var tempCityArr : [CityModel] = []
                for item in cityArr {
                    guard let cityModel = CityModel.deserialize(from: item, designatedPath: nil) else{
                        continue
                    }
                    
                    guard let areaArr = areaDic["\(cityModel.id)"] as? [[String:Any]] else{
                        continue
                    }
                    
                    var tempAreaArr : [AreaModel] = []
                    for area in areaArr {
                        guard let areaModel = AreaModel.deserialize(from: area, designatedPath: nil)else{
                            continue
                        }
                        tempAreaArr.append(areaModel)
                    }
                    cityModel.areas = tempAreaArr
                    tempCityArr.append(cityModel)
                }
                model.citys = tempCityArr
                tempProvinceArr.append(model)
            }
            return tempProvinceArr
        } catch{
            
        }
        
        
        return []
    }
}

class AddressModel:HandyJSON{
    var id : Int = 0
    var name : String = ""
    var citys : [CityModel] = []
    required init() {
        
    }
}

class CityModel:HandyJSON{
    var id : Int = 0
    var name : String = ""
    var areas : [AreaModel] = []
    required init() {
        
    }
}

class AreaModel:HandyJSON{
    var id : Int = 0
    var name : String = ""
    required init() {
        
    }
}





class SchoolNameModel: HandyJSON{
    var id : Int = 0
    var name : String = ""
    required init(){
        
    }
    
}
