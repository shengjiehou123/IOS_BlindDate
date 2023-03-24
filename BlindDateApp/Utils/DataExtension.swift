//
//  DataExtension.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/24.
//

import UIKit
import CryptoKit

extension Data{
    var sha256: String {
        return hexString(SHA256.hash(data: self).makeIterator())
    }
              
}

func hexString(_ iterator:Array<UInt8>.Iterator) -> String{
    return iterator.map{
        String(format: "%02x", $0)
    }.joined().uppercased() //字符串转成大写
}

