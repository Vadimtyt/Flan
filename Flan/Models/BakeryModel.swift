//
//  BakeryModel.swift
//  Flan
//
//  Created by Вадим on 07.05.2021.
//

import Foundation

class Bakery {
    
    // MARK: - Props
    
    let name: String
    let address: String
    let phone: String
    let workTime: String
    
    // MARK: - Initialization
    
    init(name: String, address: String, phone: String, workTime: String) {
        self.name = name
        self.address = address
        self.phone = phone
        self.workTime = workTime
    }
}
