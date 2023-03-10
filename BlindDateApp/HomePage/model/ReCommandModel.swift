//
//  ReCommandModel.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/27.
//

import UIKit
import HandyJSON

class ReCommandModel: HandyJSON,Identifiable,ObservableObject {
    var id :Int = 0
    var idVerifyed : Int = 0
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
    required  init() {
        
    }
}

class UserPhotoModel:HandyJSON,Identifiable{
    var uid :Int = 0
    var scenes:String = "life"
    var photo:String = ""
    var photoDesc:String = ""
    required  init() {
        
    }
}
