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
    var image = UIImage(named: "Кекс")
    var count = 0
    var isFavorite = false
    
    init(name: String, price: Int) {
        self.name = name
        self.price = price
    }
}

class ListOfMenuItems {
    static let shared = ListOfMenuItems()
    var items: [MenuItem] = []
    var favorites: [MenuItem] = []
    var list: [MenuItem] = []
    
    func addToList(item: MenuItem) {
        list.append(item)
    }
    
    func removeFromList(item: MenuItem) {
        if let index = list.firstIndex(where: { $0 === item }) {
            list[index].count = 0
            list.remove(at: index)
        }
    }
    
    func updateFavorites() {
        favorites.removeAll()
        for item in items {
            if item.isFavorite == true {
                favorites.append(item)
            }
        }
    }
    
    func getValueForListBadge() -> Int {
        var sumCountOfItems = 0
        
        for item in list {
            if item.count != 0 {
                sumCountOfItems += item.count
            }
        }
        return sumCountOfItems
    }
}
