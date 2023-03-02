//
//  ReCommandModel.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/2/27.
//

import UIKit
import HandyJSON

class ReCommandModel: HandyJSON,Identifiable {
    var id :Int = 0
    var idVerifyed : Int = 0
    var avatar : String = ""
    var nickName :String = ""
    var gender :Int = 0
    var birthday :Double = 0
    var height :Int = 0
    var educationType : Int = 0
    var school :String = ""
    var job :String = ""
    var yearIncome :String = ""
    var workCityCode :Int = 0
    var workCity :String = ""
    var homeTownCode:Int = 0
    var homeTown:String = ""
    var loveGoals:String = ""
    var acceptOtherPersonMinAge:Int = 18
    var acceptOtherPersonMaxAge:Int = 35
    var aboutMeDesc:String = ""
    var likePersonDesc:String = ""
    var myTag:String = ""
    var likePersonTag:String = ""
    var userPhotos: [UserPhotoModel] = []
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
