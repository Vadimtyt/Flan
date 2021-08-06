//
//  MenuItemModel.swift
//  Flan
//
//  Created by Вадим on 22.03.2021.
//

import UIKit

class MenuItem {
    
    // MARK: - Props
    
    let category: String
    let name: String
    let prices: [Int]
    let measurements: [String]
    let imageName: String
    let description: String
    var image = UIImage(named: "Кекс")
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
        self.image = UIImage(named: imageName)
        self.description = description
    }
    
    init(item: MenuItem) {
        self.category = item.category
        self.name = item.name
        self.prices = item.prices
        self.measurements = item.measurements
        self.imageName = item.imageName
        self.description = item.description
        self.image = UIImage(named: imageName)
        self.selectedMeasurment = item.selectedMeasurment
        self.count = item.count
        self.isFavorite = item.isFavorite
        
    }
}
