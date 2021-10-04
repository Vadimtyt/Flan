//
//  DataManager.swift
//  Flan
//
//  Created by Вадим on 04.08.2021.
//

import UIKit

class DataManager {
    
    static let shared = DataManager()
    
    var isOnlineMode = true
    private let defaults = UserDefaults.standard
    
    // MARK: - Props
    
    private var items = [MenuItem]()
    private var favorites = [MenuItem]()
    private var list = [MenuItem]()
    private var completedList = [MenuItem]()
    
    private var categories = [(category: String, items: [MenuItem])]()
    
    private var cakes = [Cake]()
    
    private var bakeries = [Bakery]()
    
    func configureDataFromFirebase(completion: @escaping () -> ()) {
        isOnlineMode = true
        clearAll()
        
        downloadItems { [weak self] in
            self?.downloadCakes {
                self?.downloadBakeries {
                    completion()
                }
            }
        }
    }
    
    func configureDataFromSaved() {
        isOnlineMode = false
        clearAll()
        
        setItemsFromSaved()
        setFavoritesFromSaved()
        setListFromSaved()
        setCompletedListFromSaved()
        setCakesFromSaved()
        setBakeriesFromSaved()
    }
    
    private func clearAll() {
        items.removeAll()
        favorites.removeAll()
        list.removeAll()
        completedList.removeAll()
        categories.removeAll()
        cakes.removeAll()
        bakeries.removeAll()
    }
    
    func offlineModeIsRedi() -> Bool {
        if let _ = defaults.value(forKey: KeysDefaults.items.rawValue) as? Data {
            return true
        } else { return false }
    }
    
    // MARK: - Funcs for items
    
    private func downloadItems(completion: @escaping () -> ()) {
        var itemsList = [MenuItem]()
        NetworkManager.fetchList(from: FileNameFor.items) { [weak self, isOnlineMode] (itemsFromJSON: [MenuItemJSON]?, dataJSON: Data?) in
            
            guard let itemsJSON = itemsFromJSON else {
                //self.setItemsFromSaved()
                completion()
                return
            }
            
            if let data = dataJSON {
                self?.saveItems(data: data, keyFor: .items)
            }
            
            for itemJSON in itemsJSON {
                let item = MenuItem(menuItemJSON: itemJSON)
                itemsList.append(item)
            }
            
            guard isOnlineMode else { return }
            self?.items = itemsList
            self?.configureCategories()
            self?.setFavoritesFromSaved()
            self?.setListFromSaved()
            self?.setCompletedListFromSaved()
            
            completion()
        }
    }
    
    private func saveItems(data: Data, keyFor key: KeysDefaults) {
        defaults.setValue(data, forKey: key.rawValue)
    }
    
    private func setItemsFromSaved() {
        var itemsList = [MenuItem]()
        if let data = defaults.value(forKey: KeysDefaults.items.rawValue) as? Data{
            let itemsFromJSON = try? JSONDecoder().decode([MenuItemJSON].self, from: data)
            
            guard let itemsJSON = itemsFromJSON else { return }
            for itemJSON in itemsJSON {
                let item = MenuItem(menuItemJSON: itemJSON)
                itemsList.append(item)
            }
            items = itemsList
            configureCategories()
        }
    }
    
    func getItems() -> [MenuItem] { items }
    
    // MARK: - Funcs for categories
    
    func getCategories() -> [(category: String, items: [MenuItem])] {
        return categories
    }
    
    private func configureCategories() {
        for item in items {
            if let index = categories.firstIndex(where: { $0.category == item.category }) {
                categories[index].items.append(item)
            } else { categories.append((item.category, [item])) }
        }
    }
    
    // MARK: - Funcs for favorites
    
    func getFavorites() -> [MenuItem] { favorites }
    
    private func setFavoritesFromSaved() {
        if let data = defaults.value(forKey: KeysDefaults.favorites.rawValue) as? Data{
            let favoritesFromJSON = try? JSONDecoder().decode([MenuItem].self, from: data)
            
            guard let favoritesJSON = favoritesFromJSON else { return }
            for favoriteJSON in favoritesJSON {
                if let index = items.firstIndex(where: {$0.name == favoriteJSON.name}) {
                    items[index].isFavorite = true
                    favorites.append(items[index])
                }
            }
        }
    }
    
    func updateFavorites() {
        favorites.removeAll()
        for item in items {
            if item.isFavorite == true {
                favorites.append(item)
            }
        }

        if let data = try? JSONEncoder().encode(favorites) {
            defaults.setValue(data, forKey: KeysDefaults.favorites.rawValue)
        }
    }
    
    func removeFromFavorites(item: MenuItem) {
        if let index = favorites.firstIndex(where: {$0 === item}) {
            favorites[index].isFavorite = false
        }
        updateFavorites()
    }
    
    // MARK: - Funcs for list
    
    func getList() -> [MenuItem] { list }
    
    private func setListFromSaved() {
        if let data = defaults.value(forKey: KeysDefaults.list.rawValue) as? Data{
            let listFromJSON = try? JSONDecoder().decode([MenuItem].self, from: data)
            
            guard let listJSON = listFromJSON else { return }
            for itemJSON in listJSON {
                let itemJSON = MenuItem(menuItem: itemJSON)
                if let index = items.firstIndex(where: {$0.name == itemJSON.name}) {
                    items[index].count = itemJSON.count
                    items[index].selectedMeasurment = itemJSON.selectedMeasurment
                    list.append(items[index])
                }
            }
        }
    }
    
    private func saveList() {
        if let data = try? JSONEncoder().encode(list) {
            defaults.setValue(data, forKey: KeysDefaults.list.rawValue)
        }
    }
    
    func setNewCountFor(item: MenuItem, count: Int) {
        if count > 0{
            item.count = count
            addToList(item: item)
        } else if count == 0 {
            item.count = count
            removeFromList(item: item)
        }
    }
    
    private func addToList(item: MenuItem) {
        if list.firstIndex(where: { $0 === item }) == nil {
            //list.insert(item, at: 0)
            list.append(item)
        }
        saveList()
    }
    
    private func removeFromList(item: MenuItem) {
        if let index = list.firstIndex(where: { $0 === item }) {
            list[index].count = 0
            item.selectedMeasurment = 0
            list.remove(at: index)
        }
        saveList()
    }
    
    func clearList() {
        for item in list {
            removeFromList(item: item)
        }
        saveList()
    }
    
    func getValueForListBadge() -> Int { list.count }
    
    // MARK: - Funcs for completedItems
    
    func getCompletedList() -> [MenuItem] { completedList }
    
    private func setCompletedListFromSaved() {
        if let data = defaults.value(forKey: KeysDefaults.completedList.rawValue) as? Data{
            let completedListFromJSON = try? JSONDecoder().decode([MenuItem].self, from: data)
            
            guard let completedListJSON = completedListFromJSON else { return }
            for itemJSON in completedListJSON {
                completedList.append(itemJSON)
            }
        }
    }
    
    private func saveCompletedList() {
        if let data = try? JSONEncoder().encode(completedList) {
            defaults.setValue(data, forKey: KeysDefaults.completedList.rawValue)
        }
    }
    
    func addToCompletedList(item: MenuItem) {
        completedList.insert(item, at: 0)
        saveCompletedList()
    }
    
    func removeItemFromCompletedList(at index: Int) {
        completedList.remove(at: index)
        saveCompletedList()
    }
    
    func clearCompletedList() {
        completedList.removeAll()
        saveCompletedList()
    }
    
    // MARK: - Funcs for cakes
    
    private func downloadCakes(completion: @escaping () -> ()) {
        NetworkManager.fetchList(from: FileNameFor.cakes) { [weak self, isOnlineMode] (cakesFromJSON: [CakeJSON]?, dataJSON: Data?) in
            guard isOnlineMode else { return }
            
            guard let cakesJSON = cakesFromJSON else { completion(); return }
            
            if let data = dataJSON {
                self?.saveItems(data: data, keyFor: .cakes)
            }
            
            var cakesList = [Cake]()
            for index in 0...cakesJSON.count-1 {
                let cakeJSON = cakesJSON[index]
                let cake = Cake(name: cakeJSON.name, imageName: cakeJSON.imageName)
                cakesList.append(cake)
            }
            self?.cakes = cakesList
            completion()
        }
    }
    
    private func setCakesFromSaved() {
        var cakesList = [Cake]()
        if let data = defaults.value(forKey: KeysDefaults.cakes.rawValue) as? Data{
            let cakesFromJSON = try? JSONDecoder().decode([CakeJSON].self, from: data)
            
            guard let cakesJSON = cakesFromJSON else { return }
            for index in 0...cakesJSON.count-1 {
                let cakeJSON = cakesJSON[index]
                let cake = Cake(name: cakeJSON.name, imageName: cakeJSON.imageName)
                cakesList.append(cake)
            }
            self.cakes = cakesList
        }
    }
    
    func getCakes() -> [Cake] { cakes }
    
    // MARK: - Funcs for bakery
    
    private func downloadBakeries(completion: @escaping () -> ()) {
        NetworkManager.fetchList(from: FileNameFor.bakeries) { [weak self] (bakeriesFromJSON: [Bakery]?, dataJSON: Data?) in
            if let data = dataJSON {
                self?.saveItems(data: data, keyFor: .bakeries)
            }
            
            if let bakeries = bakeriesFromJSON {
                self?.bakeries = bakeries
            }
            completion()
        }
    }
    
    private func setBakeriesFromSaved() {
        if let data = defaults.value(forKey: KeysDefaults.bakeries.rawValue) as? Data{
            let bakeriesFromJSON = try? JSONDecoder().decode([Bakery].self, from: data)
            
            if let bakeries = bakeriesFromJSON {
                self.bakeries = bakeries
            }
        }
    }
    
    
    func getBakeries() -> [Bakery] { bakeries }
}
