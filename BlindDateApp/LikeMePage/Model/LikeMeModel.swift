//
//  LikeMeModel.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/3.
//


import HandyJSON

class LikeMeModel: HandyJSON,Identifiable {
    var id : Int = 0
//    var uid : Int = 0
    var nickName:String = ""
    var avatar: String = ""
    var _avatar: String{
        return Consts.shared.imageHost + avatar
    }
    var gender :Int = 0
    var height :Int = 0
    var birthday:Double = 0
    var educationType: Int = 0
    var educationTypeDesc: String = ""
    var job :String = ""
    var school :String = ""
    required init() {
        
    }
}
