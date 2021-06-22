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
    let imageName: String
    var image = UIImage(named: "Кекс")
    var count = 0
    var isFavorite = false
    
    init(name: String, category: String, price: Int, imageName: String) {
        self.name = name
        self.category = category
        self.price = price
        self.imageName = imageName
        self.image = UIImage(named: imageName)
    }
    
    init(item: MenuItem) {
        self.name = item.name
        self.price = item.price
        self.category = item.category
        self.imageName = item.imageName
        self.image = UIImage(named: imageName)
        self.count = item.count
        self.isFavorite = item.isFavorite
    }
}

class ListOfMenuItems {
    static let shared = ListOfMenuItems()
    var items: [MenuItem] = allItems
    var favorites: [MenuItem] = []
    var list: [MenuItem] = []
    
    lazy var categories = configureCategories()
    
    func addToList(item: MenuItem) {
        guard (list.firstIndex(where: { $0 === item }) == nil) else { return }
        list.insert(item, at: 0)
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
    MenuItem(name: "Нежность", category: "Торты", price: 170, imageName: "Киш1"),
    MenuItem(name: "Киевский", category: "Торты", price: 190, imageName: "Киш2"),
    MenuItem(name: "Тирамису", category: "Торты", price: 230, imageName: "Киш3"),
    MenuItem(name: "Сочник с творогом", category: "Выпечка", price: 70, imageName: "Слойка"),
    MenuItem(name: "Плюшка", category: "Выпечка", price: 50, imageName: "Эклер1"),
    MenuItem(name: "Кекс творожный", category: "Выпечка", price: 55, imageName: "Эклер2"),
    MenuItem(name: "Зефир из натурального пюре", category: "Кендибар", price: 100, imageName: "Эклер3"),
    MenuItem(name: "Маршмеллоу", category: "Кендибар", price: 80, imageName: "Эклер4"),
    MenuItem(name: "Гимов", category: "Кендибар", price: 30, imageName: "Капкейк1"),
    MenuItem(name: "Безе", category: "Кендибар", price: 40, imageName: "Капкейк2"),
    MenuItem(name: "Безе", category: "Суфле", price: 40, imageName: "Капкейк3"),
    MenuItem(name: "Безе", category: "Пироги", price: 40, imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Печенье", price: 40, imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Кондитерка", price: 40, imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Пицца", price: 40, imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Киши", price: 40, imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Супы", price: 40, imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Конфеты", price: 40, imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Кексы", price: 40, imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Салаты", price: 40, imageName: "Кекс")
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
