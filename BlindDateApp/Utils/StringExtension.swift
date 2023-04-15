//
//  StringExtension.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/9.
//

import UIKit
import Foundation
import CommonCrypto

extension String:Identifiable{
    public typealias ID = UUID
    public var id: UUID {
        return UUID()
    }
    
}

extension String{
    //将原始的url编码为合法的url
       func urlEncoded() -> String {
           let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
               .urlQueryAllowed)
           return encodeUrlString ?? ""
       }
        
       //将编码后的url转换回原始的url
       func urlDecoded() -> String {
           return self.removingPercentEncoding ?? ""
       }
    
    func stringToDate(format:String) ->Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self) ?? nil
        return date
    }
    
    
    func formatPhoneNumber() -> String {
        let regex = try! NSRegularExpression(pattern: "(\\d{3})(\\d{3})(\\d{4})", options: [])
        let range = NSRange(location: 0, length: self.utf16.count)
        let formattedNumber = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "($1) $2-$3")
        return formattedNumber
    }

    
}
