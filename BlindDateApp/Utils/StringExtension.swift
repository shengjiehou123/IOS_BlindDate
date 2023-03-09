//
//  StringExtension.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/9.
//

import UIKit

extension String:Identifiable{
    public typealias ID = UUID
    public var id: UUID {
        return UUID()
    }
}
