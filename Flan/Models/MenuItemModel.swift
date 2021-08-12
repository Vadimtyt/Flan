//
//  MenuItemModel.swift
//  Flan
//
//  Created by Вадим on 22.03.2021.
//

import UIKit

class MenuItem {
    
    private let standartImage = UIImage(named: "Кекс.jpg")!
    
    // MARK: - Props
    
    let category: String
    let name: String
    let prices: [Int]
    let measurements: [String]
    let imageName: String
    let description: String
    var image: UIImage
    var selectedMeasurment = 0
    var count = 0
    var isFavorite = false
    
    // MARK: - Initializations
    
    init(category: String, name: String, prices: [Int], measurements: [String], imageName: String, description: String) {
        self.category = category
        self.name = name
        self.prices = prices
        self.measurements = measurements
        self.imageName = imageName
        self.description = description
        self.image = standartImage
    }
    
    init(item: MenuItem) {
        self.category = item.category
        self.name = item.name
        self.prices = item.prices
        self.measurements = item.measurements
        self.imageName = item.imageName
        self.description = item.description
        self.image = item.image
        self.selectedMeasurment = item.selectedMeasurment
        self.count = item.count
        self.isFavorite = item.isFavorite
    }
    
    init(menuItemJSON: MenuItemJSON) {
        self.category = menuItemJSON.category
        self.name = menuItemJSON.name
        if menuItemJSON.prices.count == 0 {
            self.prices = [0]
        } else { self.prices = menuItemJSON.prices }
        if menuItemJSON.measurements.count == 0 {
            self.measurements = [""]
        } else { self.measurements = menuItemJSON.measurements }
        self.imageName = menuItemJSON.imageName
        self.description = menuItemJSON.description
        self.image = standartImage
    }
    
    func setImage(completion: @escaping (UIImage) -> ()) {
        guard self.image == standartImage else { completion(self.image); return }
        if let assetsImage = UIImage(named: imageName) {
            self.image = assetsImage
            completion(self.image)
        } else {
            NetworkManager.fetchImage("Пирог с капустой.jpg") { image in
                self.image = image
                completion(self.image)
            }
        }
    }
}

class MenuItemJSON: Decodable {
    let category: String
    let name: String
    let prices: [Int]
    let measurements: [String]
    let imageName: String
    let description: String
    
    init(from MenuItemJSON: MenuItemJSON) {
        category = MenuItemJSON.category
        name = MenuItemJSON.name
        prices = MenuItemJSON.prices
        measurements = MenuItemJSON.measurements
        imageName = MenuItemJSON.imageName
        description = MenuItemJSON.description
    }
}
