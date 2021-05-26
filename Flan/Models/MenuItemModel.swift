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
    let category: String
    var image = UIImage(named: "Кекс")
    var count = 0
    var isFavorite = false
    
    init(name: String, category: String, price: Int) {
        self.name = name
        self.category = category
        self.price = price
    }
}

class ListOfMenuItems {
    static let shared = ListOfMenuItems()
    var items: [MenuItem] = allItems
    var favorites: [MenuItem] = []
    var list: [MenuItem] = []
    
    lazy var categories = configureCategories()
    
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
    
    func configureCategories() -> [(category: String, items: [MenuItem])] {
        var categories: [(category: String, items: [MenuItem])] = []
        for item in items {
            if let index = categories.firstIndex(where: { $0.category == item.category }) {
                categories[index].items.append(item)
            } else { categories.append((item.category, [item])) }
        }
        return categories
    }
    
}

let allItems: [MenuItem] = [
    MenuItem(name: "Нежность", category: "Торты", price: 170),
    MenuItem(name: "Киевский", category: "Торты", price: 190),
    MenuItem(name: "Тирамису", category: "Торты", price: 230),
    MenuItem(name: "Сочник с творогом", category: "Выпечка", price: 70),
    MenuItem(name: "Плюшка", category: "Выпечка", price: 50),
    MenuItem(name: "Кекс творожный", category: "Выпечка", price: 55),
    MenuItem(name: "Зевиф из натурального пюре", category: "Кендибар", price: 100),
    MenuItem(name: "Маршмеллоу", category: "Кендибар", price: 80),
    MenuItem(name: "Гимов", category: "Кендибар", price: 30),
    MenuItem(name: "Безе", category: "Кендибар", price: 40)
]

extension RangeReplaceableCollection where Element: Hashable {
    var orderedSet: Self {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
    mutating func removeDuplicates() {
        var set = Set<Element>()
        removeAll { !set.insert($0).inserted }
    }
}
