//
//  MenuItem.swift
//  Flan
//
//  Created by Вадим on 22.03.2021.
//

import UIKit

class MenuItem {
    
    // MARK: - Props
    
    let name: String
    let category: String
    let prices: [Int]
    let measurements: [String]
    let imageName: String
    let description: String
    var image = UIImage(named: "Кекс")
    var selectedMeasurment = 0
    var count = 0
    var isFavorite = false
    
    // MARK: - Initializations
    
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
