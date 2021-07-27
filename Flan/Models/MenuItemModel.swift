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
    let description: String
    var image = UIImage(named: "Кекс")
    var count = 0
    var isFavorite = false
    
    init(name: String, category: String, prices: [Int], measurements: [String], imageName: String, description: String) {
        self.name = name
        self.category = category
        self.prices = prices
        self.measurements = measurements
        self.imageName = imageName
        self.image = UIImage(named: imageName)
        self.description = description
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
        self.description = item.description
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
        //list.insert(item, at: 0)
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
    
    func removeFromFavorites(item: MenuItem) {
        if let index = favorites.firstIndex(where: {$0 === item}) {
            favorites[index].isFavorite = false
        }
        updateFavorites()
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
    MenuItem(name: "Нежность", category: "Торты", prices: [170], measurements: ["100г"], imageName: "Киш1", description: "Описание"),
    MenuItem(name: "Киевский", category: "Торты", prices: [190], measurements: ["100г"], imageName: "Киш2", description: "Описание"),
    MenuItem(name: "Тирамису", category: "Торты", prices: [1500], measurements: ["100г"], imageName: "Киш3", description: "Описание"),
    MenuItem(name: "Сочник с творогом", category: "Выпечка", prices: [70], measurements: ["шт"], imageName: "Слойка", description: "Описание"),
    MenuItem(name: "Плюшка", category: "Выпечка", prices: [50, 300], measurements: ["шт", "целый"], imageName: "Эклер1", description: "Он родился как ремейк на тему  детских воспоминаний о вкуснейшем бабушкином торте, выполненном из качественнейших ( как и все домашнее) продуктов по современной технологии. В нем нежнейшие шоколадные бисквиты чередуются с белым сливочным бисквитом , которые прослоены сметано-творожным кремом, тающим во рту."),
    MenuItem(name: "Кекс творожный", category: "Выпечка", prices: [55], measurements: ["шт"], imageName: "Эклер2", description: "Описание"),
    MenuItem(name: "Зефир из натурального пюре", category: "Кендибар", prices: [100], measurements: ["шт"], imageName: "Эклер3", description: "Описание"),
    MenuItem(name: "Маршмеллоу", category: "Кендибар", prices: [80], measurements: ["шт"], imageName: "Эклер4", description: "Описание"),
    MenuItem(name: "Гимов", category: "Кендибар", prices: [30], measurements: ["шт"], imageName: "Капкейк1", description: "Описание"),
    MenuItem(name: "Корзиночка с йогуртовым кремом", category: "Кендибар", prices: [40], measurements: ["шт"], imageName: "Капкейк2", description: "Описание"),
    MenuItem(name: "Торт бисквитный со сметанным кремом", category: "Суфле", prices: [40], measurements: ["шт"], imageName: "Капкейк3", description: "Он родился как ремейк на тему  детских воспоминаний о вкуснейшем бабушкином торте, выполненном из качественнейших ( как и все домашнее) продуктов по современной технологии. В нем нежнейшие шоколадные бисквиты чередуются с белым сливочным бисквитом , которые прослоены сметано-творожным кремом, тающим во рту."),
    MenuItem(name: "Безе", category: "Пироги", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(name: "Безе", category: "Печенье", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(name: "Безе", category: "Кондитерка", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(name: "Безе", category: "Пицца", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(name: "Безе", category: "Киши", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(name: "Безе", category: "Супы", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(name: "Безе", category: "Конфеты", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(name: "Безе", category: "Кексы", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(name: "Безе", category: "Салаты", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание")
]
