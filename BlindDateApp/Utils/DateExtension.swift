//
//  DateExtension.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/2.
//

import Foundation

extension Date{
    func stringFormat(format:String) -> String{
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = format
       return dateFormatter.string(from: self)
    }
    
    func getAge() -> Int{
        let calendar = NSCalendar.current
        let components = Calendar.Component.year
        let currentDate = Date()
        let age = calendar.component(components, from: currentDate) - calendar.component(components, from: self) + 1
        return age
    }
}
