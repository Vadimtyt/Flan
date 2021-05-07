//
//  BakeryModel.swift
//  Flan
//
//  Created by Вадим on 07.05.2021.
//

import Foundation

class Bakery {
    let name: String
    let address: String
    let phone: String
    let openTime: Int
    let closeTime: Int
    
    init(name: String, address: String, phone: String, openTime: Int, closeTime: Int) {
        self.name = name
        self.address = address
        self.phone = phone
        self.openTime = openTime
        self.closeTime = closeTime
    }
}
