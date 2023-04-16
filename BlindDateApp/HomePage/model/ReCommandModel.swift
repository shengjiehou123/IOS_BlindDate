//
//  ReCommandModel.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/27.
//

import UIKit
import HandyJSON
import XCGLogger

class ReCommandModel: HandyJSON,Identifiable,Equatable {
    var id :Int = 0
    var idVerifyed : Int = 0
    var _avatar : String{
        return Consts.shared.imageHost + avatar
    }
    var phoneNumber : String = ""
    var avatar : String = ""
    var nickName :String = ""
    var gender :Int = 0
    var birthday :Double = 0
    var height :Int = 0
    var educationType : Int = 0
    var educationTypeDesc : String = ""
    var school :String = ""
    var job :String = ""
    var yearIncome :Int = 0
    var yearIncomeDesc :String = ""
    
    var workProvinceCode :Int = 0
    var workProvinceName :String = ""
    var workCityCode :Int = 0
    var workCityName :String = ""
    var workAreaCode :Int = 0
    var workAreaName :String = ""
    
    var homeTownProvinceCode :Int = 0
    var homeTownProvinceName :String = ""
    var homeTownCityCode :Int = 0
    var homeTownCityName :String = ""
    var homeTownAreaCode :Int = 0
    var homeTownAreaName :String = ""
    var loveGoals:Int = 0
    var loveGoalsDesc:String = ""
    var acceptOtherPersonMinAge:Int = 18
    var acceptOtherPersonMaxAge:Int = 35
    var aboutMeDesc:String = ""
    var myTag:String = ""
    var likePersonTag:String = ""
    var userPhotos: [UserPhotoModel] = []
    var bgImageId : Int = 0
    var bgImageUrl : String = ""
    var _bgImageUrl : String{
        return Consts.shared.imageHost + bgImageUrl
    }
    static func == (lhs: ReCommandModel, rhs: ReCommandModel) -> Bool{
        return lhs.id == rhs.id
    }
    required  init() {
        
    }
}

class UserPhotoModel:HandyJSON,Identifiable,Equatable{
    static func == (lhs: UserPhotoModel, rhs: UserPhotoModel) -> Bool{
        return lhs.id == rhs.id
    }
    var id : Int = 0
    var uid :Int = 0
    var scenes:String = "life"
    var photo : String = ""
    var _photo:String{
        return Consts.shared.imageHost + photo
    }
    var width:Int = 0
    var height:Int = 0
    var photoDesc:String = ""
    required  init() {
        
    }
}
