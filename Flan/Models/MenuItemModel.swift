//
//  MenuItem.swift
//  Flan
//
//  Created by Вадим on 22.03.2021.
//

import UIKit

class MenuItem {
    let name: String
    let prices: [Int]
    let measurements: [String]
    var selectedMeasurment = 0
    let category: String
    let imageName: String
    var image = UIImage(named: "Кекс")
    var count = 0
    var isFavorite = false
    
    init(name: String, category: String, prices: [Int], measurements: [String], imageName: String) {
        self.name = name
        self.category = category
        self.prices = prices
        self.measurements = measurements
        self.imageName = imageName
        self.image = UIImage(named: imageName)
    }
    
    init(item: MenuItem) {
        self.name = item.name
        self.prices = item.prices
        self.measurements = item.measurements
        self.selectedMeasurment = item.selectedMeasurment
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
        //list.insert(item, at: list.count - 1)
        list.append(item)
    }
    
    func removeFromList(item: MenuItem) {
        if let index = list.firstIndex(where: { $0 === item }) {
            list[index].count = 0
            item.selectedMeasurment = 0
            list.remove(at: index)
        }
    }
    
    func clearList() {
        for item in list {
            removeFromList(item: item)
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
    MenuItem(name: "Нежность", category: "Торты", prices: [170], measurements: ["100г"], imageName: "Киш1"),
    MenuItem(name: "Киевский", category: "Торты", prices: [190], measurements: ["100г"], imageName: "Киш2"),
    MenuItem(name: "Тирамису", category: "Торты", prices: [230], measurements: ["100г"], imageName: "Киш3"),
    MenuItem(name: "Сочник с творогом", category: "Выпечка", prices: [70], measurements: ["шт"], imageName: "Слойка"),
    MenuItem(name: "Плюшка", category: "Выпечка", prices: [50, 300], measurements: ["шт", "целый"], imageName: "Эклер1"),
    MenuItem(name: "Кекс творожный", category: "Выпечка", prices: [55], measurements: ["шт"], imageName: "Эклер2"),
    MenuItem(name: "Зефир из натурального пюре", category: "Кендибар", prices: [100], measurements: ["шт"], imageName: "Эклер3"),
    MenuItem(name: "Маршмеллоу", category: "Кендибар", prices: [80], measurements: ["шт"], imageName: "Эклер4"),
    MenuItem(name: "Гимов", category: "Кендибар", prices: [30], measurements: ["шт"], imageName: "Капкейк1"),
    MenuItem(name: "Безе", category: "Кендибар", prices: [40], measurements: ["шт"], imageName: "Капкейк2"),
    MenuItem(name: "Безе", category: "Суфле", prices: [40], measurements: ["шт"], imageName: "Капкейк3"),
    MenuItem(name: "Безе", category: "Пироги", prices: [40], measurements: ["шт"], imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Печенье", prices: [40], measurements: ["шт"], imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Кондитерка", prices: [40], measurements: ["шт"], imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Пицца", prices: [40], measurements: ["шт"], imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Киши", prices: [40], measurements: ["шт"], imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Супы", prices: [40], measurements: ["шт"], imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Конфеты", prices: [40], measurements: ["шт"], imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Кексы", prices: [40], measurements: ["шт"], imageName: "Кекс"),
    MenuItem(name: "Безе", category: "Салаты", prices: [40], measurements: ["шт"], imageName: "Кекс")
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
