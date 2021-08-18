//
//  DataManager.swift
//  Flan
//
//  Created by Вадим on 04.08.2021.
//

import UIKit

class DataManager {
    
    static let shared = DataManager()
    
    // MARK: - Props
    
    private var items: [MenuItem] = []
    private var favorites: [MenuItem] = []
    private var list: [MenuItem] = []
    private var completedList: [MenuItem] = []
    
    private var categories: [(category: String, items: [MenuItem])] = []
    
    private var cakes: [Cake] = []
    
    private var bakeries: [Bakery] = []
    
    func configureData(completion: @escaping () -> ()) {
        configureItems {
            self.configureCakes {
                self.configureBakeries {
                    completion()
                }
            }
        }
    }
    
    // MARK: - Funcs for items
    
    func configureItems(completion: @escaping () -> ()) {
        
        var itemsList: [MenuItem] = []
        NetworkManager.fetchList(from: FileNameFor.items) { [] (itemsFromJSON: [MenuItemJSON]?) in
            guard let itemsJSON = itemsFromJSON else { completion(); return }
            for itemJSON in itemsJSON {
                let item = MenuItem(from: itemJSON)
                itemsList.append(item)
            }
            self.items = itemsList
            self.configureCategories()
            completion()
        }
    }
    
    func getItems() -> [MenuItem]{
        return items
    }
    
    // MARK: - Funcs for categories
    
    func getCategories() -> [(category: String, items: [MenuItem])] {
        return categories
    }
    
    func configureCategories() {
        
        var categories: [(category: String, items: [MenuItem])] = []
        for item in items {
            if let index = categories.firstIndex(where: { $0.category == item.category }) {
                categories[index].items.append(item)
            } else { categories.append((item.category, [item])) }
        }
        self.categories = categories
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
    
    func configureCakes(completion: @escaping () -> ()) {
        
        NetworkManager.fetchList(from: FileNameFor.cakes) { [] (cakesFromJSON: [CakeJSON]?) in
            guard let cakesJSON = cakesFromJSON else { completion(); return }
            var cakesList: [Cake] = []
            for index in 0...cakesJSON.count-1 {
                let cakeJSON = cakesJSON[index]
                let cake = Cake(number: index + 1, imageName: cakeJSON.imageName)
                cakesList.append(cake)
            }
            self.cakes = cakesList
            completion()
        }
    }
    
    func getCakes() -> [Cake] {
        return cakes
    }
    
    // MARK: - Funcs for bakery
    
    func configureBakeries(completion: @escaping () -> ()) {
        NetworkManager.fetchList(from: FileNameFor.bakeries) { [] (bakeriesFromJSON: [Bakery]?) in
            
            if let bakeries = bakeriesFromJSON {
                self.bakeries = bakeries
            } else { self.bakeries = bakeriesList}
            completion()
        }
    }
    
    func getBakeries() -> [Bakery] {
        return bakeries
    }
}

private let bakeriesList = [
    Bakery(name: "Флан на Новой", address: "ул.Новая, 14А", phone: "+7(989)248-14-14", workTime: "10:00-20:00 Ежедневно"),
    Bakery(name: "Флан на Отдельской", address: "ул.Отдельская 324/7", phone: "+7(988)135-07-07", workTime: "9:00-22:00 Ежедневно"),
    Bakery(name: "Флан на Школьной", address: "ул.Школьная, 301А", phone: "+7(918)123-45-67", workTime: "8:00-20:00 ПН-ПТ"),
    Bakery(name: "Флан на Лермонтова", address: "ул.Лермонтова, 216Г", phone: "+7(988)316-21-21", workTime: "8:00-22:00 Ежедневно")
]

//private let allItems: [MenuItem] = [
//    MenuItem(category: "Торты", name: "Нежность", prices: [170], measurements: ["100г"], imageName: "Киш1", description: "Описание"),
//    MenuItem(category: "Торты", name: "Киевский", prices: [190], measurements: ["100г"], imageName: "Киш2", description: "Описание"),
//    MenuItem(category: "Торты", name: "Тирамису", prices: [1500], measurements: ["100г"], imageName: "Киш3", description: "Описание"),
//    MenuItem(category: "Выпечка", name: "Сочник с творогом", prices: [70], measurements: ["шт"], imageName: "Слойка", description: "Описание"),
//    MenuItem(category: "Выпечка", name: "Плюшка", prices: [50, 300], measurements: ["шт", "целый"], imageName: "Эклер1", description: "Он родился как ремейк на тему  детских воспоминаний о вкуснейшем бабушкином торте, выполненном из качественнейших ( как и все домашнее) продуктов по современной технологии. В нем нежнейшие шоколадные бисквиты чередуются с белым сливочным бисквитом , которые прослоены сметано-творожным кремом, тающим во рту."),
//    MenuItem(category: "Выпечка", name: "Кекс творожный", prices: [55], measurements: ["шт"], imageName: "Эклер2", description: "Описание"),
//    MenuItem(category: "Кендибар", name: "Зефир из натурального пюре", prices: [100], measurements: ["шт"], imageName: "Эклер3", description: "Описание"),
//    MenuItem(category: "Кендибар", name: "Маршмеллоу", prices: [80], measurements: ["шт"], imageName: "Эклер4", description: "Описание"),
//    MenuItem(category: "Кендибар", name: "Гимов", prices: [30], measurements: ["шт"], imageName: "Капкейк1", description: "Описание"),
//    MenuItem(category: "Кендибар", name: "Корзиночка с йогуртовым кремом", prices: [40], measurements: ["шт"], imageName: "Капкейк2", description: "Описание"),
//    MenuItem(category: "Суфле", name: "Торт бисквитный со сметанным кремом", prices: [40], measurements: ["шт"], imageName: "Капкейк3", description: "Он родился как ремейк на тему  детских воспоминаний о вкуснейшем бабушкином торте, выполненном из качественнейших ( как и все домашнее) продуктов по современной технологии. В нем нежнейшие шоколадные бисквиты чередуются с белым сливочным бисквитом , которые прослоены сметано-творожным кремом, тающим во рту."),
//    MenuItem(category: "Слоеная выпечка", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
//    MenuItem(category: "Печенье", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
//    MenuItem(category: "Кондитерка", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
//    MenuItem(category: "Пицца", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
//    MenuItem(category: "Киши", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
//    MenuItem(category: "Супы", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
//    MenuItem(category: "Конфеты", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
//    MenuItem(category: "Кексы", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание"),
//    MenuItem(category: "Салаты", name: "Безе", prices: [40], measurements: ["шт"], imageName: "Кекс", description: "Описание")
//]

//private let cakesList = [
//    Cake(number: 1, imageName: "Photo1.jpg"),
//    Cake(number: 2, imageName: "Photo2.jpg"),
//    Cake(number: 3, imageName: "Photo3.jpg"),
//    Cake(number: 4, imageName: "Photo4.jpg"),
//    Cake(number: 5, imageName: "Photo5.jpg"),
//    Cake(number: 6, imageName: "Photo6.jpg"),
//    Cake(number: 7, imageName: "Photo7.jpg"),
//    Cake(number: 8, imageName: "Photo8.jpg"),
//    Cake(number: 9, imageName: "Photo9.jpg"),
//    Cake(number: 10, imageName: "Photo10.jpg"),
//    Cake(number: 11, imageName: "Photo11.jpg"),
//    Cake(number: 12, imageName: "Photo12.jpg"),
//    Cake(number: 13, imageName: "Photo13.jpg"),
//    Cake(number: 14, imageName: "Photo14.jpg"),
//    Cake(number: 15, imageName: "Photo15.jpg"),
//    Cake(number: 16, imageName: "Photo16.jpg"),
//    Cake(number: 17, imageName: "Photo17.jpg"),
//    Cake(number: 18, imageName: "Photo18.jpg"),
//    Cake(number: 19, imageName: "Photo19.jpg"),
//    Cake(number: 20, imageName: "Photo20.jpg"),
//    Cake(number: 21, imageName: "Photo21.jpg"),
//    Cake(number: 22, imageName: "Photo22.jpg"),
//    Cake(number: 23, imageName: "Photo23.jpg"),
//    Cake(number: 24, imageName: "Photo24.jpg"),
//    Cake(number: 25, imageName: "Photo25.jpg"),
//    Cake(number: 26, imageName: "Photo26.jpg"),
//    Cake(number: 27, imageName: "Photo27.jpg"),
//    Cake(number: 28, imageName: "Photo28.jpg"),
//    Cake(number: 29, imageName: "Photo29.jpg"),
//    Cake(number: 30, imageName: "Photo30.jpg"),
//    Cake(number: 31, imageName: "Photo31.jpg"),
//    Cake(number: 32, imageName: "Photo32.jpg"),
//    Cake(number: 33, imageName: "Photo33.jpg"),
//    Cake(number: 34, imageName: "Photo34.jpg"),
//    Cake(number: 35, imageName: "Photo35.jpg"),
//    Cake(number: 36, imageName: "Photo36.jpg"),
//    Cake(number: 37, imageName: "Photo37.jpg"),
//    Cake(number: 38, imageName: "Photo38.jpg"),
//    Cake(number: 39, imageName: "Photo39.jpg"),
//    Cake(number: 40, imageName: "Photo40.jpg"),
//    Cake(number: 41, imageName: "Photo41.jpg"),
//    Cake(number: 42, imageName: "Photo42.jpg"),
//    Cake(number: 43, imageName: "Photo43.jpg"),
//    Cake(number: 44, imageName: "Photo44.jpg"),
//    Cake(number: 45, imageName: "Photo45.jpg"),
//    Cake(number: 46, imageName: "Photo46.jpg"),
//    Cake(number: 47, imageName: "Photo47.jpg"),
//    Cake(number: 48, imageName: "Photo48.jpg"),
//    Cake(number: 49, imageName: "Photo49.jpg"),
//    Cake(number: 50, imageName: "Photo50.jpg"),
//    Cake(number: 51, imageName: "Photo51.jpg"),
//    Cake(number: 52, imageName: "Photo52.jpg"),
//    Cake(number: 53, imageName: "Photo53.jpg"),
//    Cake(number: 54, imageName: "Photo54.jpg"),
//    Cake(number: 55, imageName: "Photo55.jpg"),
//    Cake(number: 56, imageName: "Photo56.jpg"),
//    Cake(number: 57, imageName: "Photo57.jpg"),
//    Cake(number: 58, imageName: "Photo58.jpg"),
//    Cake(number: 59, imageName: "Photo59.jpg")
//]
