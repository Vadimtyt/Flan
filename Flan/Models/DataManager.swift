//
//  DataManager.swift
//  Flan
//
//  Created by Вадим on 04.08.2021.
//

import UIKit

class DataManager {
    
    // MARK: - Props
    
    static let shared = DataManager()
    private var items: [MenuItem] = []
    private var favorites: [MenuItem] = []
    private var list: [MenuItem] = []
    private var completedList: [MenuItem] = []
    
    private lazy var categories: [(category: String, items: [MenuItem])] = []
    
    private var cakes: [Cake] = []
    
    private var bakeries: [Bakery] = bakeriesList
    
    // MARK: - Funcs for items
    
    func configureItems() {
        var list: [MenuItem] = []
        NetworkManager.fetchList { [] listOfItemsJSON in
            for itemJSON in listOfItemsJSON {
                let item = MenuItem(menuItemJSON: itemJSON)
                list.append(item)
            }
            self.items = list
            self.categories = self.configureCategories()
        }
    }
    
    func getItems() -> [MenuItem]{
        return items
    }
    
    // MARK: - Funcs for categories
    
    func getCategories() -> [(category: String, items: [MenuItem])] {
        return categories
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
    
    // MARK: - Funcs for favorites
    
    func getFavorites() -> [MenuItem]{
        return favorites
    }
    
    func updateFavorites() {
        favorites.removeAll()
        for item in items {
            if item.isFavorite == true {
                favorites.append(item)
            }
        }
    }
    
    func removeFromFavorites(item: MenuItem) {
        if let index = favorites.firstIndex(where: {$0 === item}) {
            favorites[index].isFavorite = false
        }
        updateFavorites()
    }
    
    // MARK: - Funcs for list
    
    func getList() -> [MenuItem]{
        return list
    }
    
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
    
    func getValueForListBadge() -> Int {
        var sumCountOfItems = 0
        
        for item in list {
            if item.count != 0 {
                sumCountOfItems += item.count
            }
        }
        return sumCountOfItems
    }
    
    // MARK: - Funcs for completedItems
    
    func getCompletedList() -> [MenuItem] {
        return completedList
    }
    
    func addToCompletedList(item: MenuItem) {
        completedList.insert(item, at: 0)
    }
    
    func removeItemFromCompletedList(at index: Int) {
        completedList.remove(at: index)
    }
    
    func clearCompletedList() {
        completedList.removeAll()
    }
    
    // MARK: - Funcs for cakes
    
    func getCakes() -> [Cake] {
        return cakesList
    }
    
    // MARK: - Funcs for bakery
    
    func getBakeries() -> [Bakery] {
        return bakeries
    }
}

private let allItems: [MenuItem] = [
    MenuItem(category: "Торты", name: "Нежность", prices: [170], measurements: ["100г"], imageName: "Киш1", description: "Описание"),
    MenuItem(category: "Торты", name: "Киевский", prices: [190], measurements: ["100г"], imageName: "Киш2", description: "Описание"),
    MenuItem(category: "Торты", name: "Тирамису", prices: [1500], measurements: ["100г"], imageName: "Киш3", description: "Описание"),
    MenuItem(category: "Выпечка", name: "Сочник с творогом", prices: [70], measurements: ["шт"], imageName: "Слойка", description: "Описание"),
    MenuItem(category: "Выпечка", name: "Плюшка", prices: [50, 300], measurements: ["шт", "целый"], imageName: "Эклер1", description: "Он родился как ремейк на тему  детских воспоминаний о вкуснейшем бабушкином торте, выполненном из качественнейших ( как и все домашнее) продуктов по современной технологии. В нем нежнейшие шоколадные бисквиты чередуются с белым сливочным бисквитом , которые прослоены сметано-творожным кремом, тающим во рту."),
    MenuItem(category: "Выпечка", name: "Кекс творожный", prices: [55], measurements: ["шт"], imageName: "Эклер2", description: "Описание"),
    MenuItem(category: "Кендибар", name: "Зефир из натурального пюре", prices: [100], measurements: ["шт"], imageName: "Эклер3", description: "Описание"),
    MenuItem(category: "Кендибар", name: "Маршмеллоу", prices: [80], measurements: ["шт"], imageName: "Эклер4", description: "Описание"),
    MenuItem(category: "Кендибар", name: "Гимов", prices: [30], measurements: ["шт"], imageName: "Капкейк1", description: "Описание"),
    MenuItem(category: "Кендибар", name: "Корзиночка с йогуртовым кремом", prices: [40], measurements: ["шт"], imageName: "Капкейк2", description: "Описание"),
    MenuItem(category: "Суфле", name: "Торт бисквитный со сметанным кремом", prices: [40], measurements: ["шт"], imageName: "Капкейк3", description: "Он родился как ремейк на тему  детских воспоминаний о вкуснейшем бабушкином торте, выполненном из качественнейших ( как и все домашнее) продуктов по современной технологии. В нем нежнейшие шоколадные бисквиты чередуются с белым сливочным бисквитом , которые прослоены сметано-творожным кремом, тающим во рту."),
    MenuItem(category: "Слоеная выпечка", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(category: "Печенье", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(category: "Кондитерка", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(category: "Пицца", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(category: "Киши", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(category: "Супы", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(category: "Конфеты", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(category: "Кексы", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
    MenuItem(category: "Салаты", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание")
]

private let cakesList = [
    Cake(number: 1, image: UIImage(named: "Слойка")!),
    Cake(number: 2, image: UIImage(named: "Киш3")!),
    Cake(number: 3, image: UIImage(named: "Эклер3")!),
    Cake(number: 4, image: UIImage(named: "Эклер1")!),
    Cake(number: 5, image: UIImage(named: "Кекс")!),
    Cake(number: 6, image: UIImage(named: "Киш3")!),
    Cake(number: 7, image: UIImage(named: "Эклер3")!),
    Cake(number: 8, image: UIImage(named: "Кекс")!),
    Cake(number: 9, image: UIImage(named: "Слойка")!),
    Cake(number: 10, image: UIImage(named: "Кекс")!),
    Cake(number: 11, image: UIImage(named: "Киш3")!),
    Cake(number: 12, image: UIImage(named: "Эклер3")!),
    Cake(number: 13, image: UIImage(named: "Кекс")!),
    Cake(number: 14, image: UIImage(named: "Киш3")!),
    Cake(number: 15, image: UIImage(named: "Слойка")!),
    Cake(number: 16, image: UIImage(named: "Эклер1")!),
    Cake(number: 17, image: UIImage(named: "Кекс")!),
    Cake(number: 18, image: UIImage(named: "Киш3")!)
]

let cakesNames = ["Кекс", "Киш3", "Капкейк1", "Эклер3", "Киш3", "Слойка", "Эклер2", "Эклер1"]

private let bakeriesList = [
    //Bakery(name: "Флан на Новой", address: "ул.Дорожная, 5 к1", phone: "+7(989)248-14-14", openTime: 8, closeTime: 21),
    Bakery(name: "Флан на Новой", address: "ул.Новая, 14А", phone: "+7(989)248-14-14", workTime: "10:00-20:00 ежедневно"),
    Bakery(name: "Флан на Отдельской", address: "ул.Отдельская 324/7", phone: "+7(988)135-07-07", workTime: "9:00-22:00 ежедневно"),
    Bakery(name: "Флан на Школьной", address: "ул.Школьная, 301А", phone: "+7(918)123-45-67", workTime: "8:00-20:00 пн-пт"),
    Bakery(name: "Флан на Лермонтова", address: "ул.Лермонтова, 216Г", phone: "+7(988)316-21-21", workTime: "8:00-22:00 ежедневно")
]
