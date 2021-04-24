//
//  MenuItem.swift
//  Flan
//
//  Created by Вадим on 22.03.2021.
//

import UIKit

class MenuItem {
    let name: String
    let price: Int
    var image = UIImage(named: "downloading_icon 13.04.59")
    var count = 0
    
    init(name: String, price: Int) {
        self.name = name
        self.price = price
    }
}

class ListOfMenuItems {
    static let shared = ListOfMenuItems()
    var list: [MenuItem] = []
}
