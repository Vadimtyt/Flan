//
//  MenuItemModel.swift
//  Flan
//
//  Created by Вадим on 22.03.2021.
//

import UIKit

class MenuItem: MenuItemJSON {
    
    private let standartImage = UIImage(named: "Кекс.jpg")!
    
    // MARK: - Props
    
    private var image: UIImage
    var selectedMeasurment = 0
    var count = 0
    var isFavorite = false
    
    // MARK: - Initializations
    init(from menuItemJSON: MenuItemJSON) {
        self.image = standartImage

        var prices: [Int] = []
        if menuItemJSON.prices.count == 0 {
            prices = [0]
        } else { prices = menuItemJSON.prices }
        
        var measurements: [String] = []
        if menuItemJSON.measurements.count == 0 {
            measurements = [""]
        } else { measurements = menuItemJSON.measurements }

        super.init(category: menuItemJSON.category,
                   name: menuItemJSON.name,
                   prices: prices,
                   measurements: measurements,
                   imageName: menuItemJSON.imageName,
                   description: menuItemJSON.description)
    }
    
    init() {
        self.image = standartImage
        super.init(category: "category",
                   name: "name",
                   prices: [0],
                   measurements: [""],
                   imageName: "imageName",
                   description: "description")
    }
    
    override init(category: String, name: String, prices: [Int], measurements: [String], imageName: String, description: String) {

        self.image = standartImage
        super.init(category: category,
                   name: name,
                   prices: prices,
                   measurements: measurements,
                   imageName: imageName,
                   description: description)
    }
    
    init(item: MenuItem) {

        self.image = item.image
        self.selectedMeasurment = item.selectedMeasurment
        self.count = item.count
        self.isFavorite = item.isFavorite
        super.init(category: item.category,
                   name: item.name,
                   prices: item.prices,
                   measurements: item.measurements,
                   imageName: item.imageName,
                   description: item.description)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func setImage(completion: @escaping (UIImage) -> ()) {
        guard self.image == standartImage else { completion(self.image); return }
        if let assetsImage = UIImage(named: imageName) {
            self.image = assetsImage
            completion(self.image)
        } else {
            NetworkManager.fetchImage(self.imageName) { image in
                self.image = image
                completion(self.image)
            }
        }
    }
}

class MenuItemJSON: Decodable {
    let category: String
    let name: String
    var prices: [Int]
    var measurements: [String]
    var imageName: String
    var description: String
    
    init(category: String, name: String, prices: [Int], measurements: [String], imageName: String, description: String) {
        self.category = category
        self.name = name
        self.prices = prices
        self.measurements = measurements
        self.imageName = imageName
        self.description = description
    }
}
