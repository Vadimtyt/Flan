//
//  MenuItemModel.swift
//  Flan
//
//  Created by Вадим on 22.03.2021.
//

import UIKit

class MenuItem: MenuItemJSON {
    
    private let standartImage = UIImage(named: "Standart image.jpg")!
    
    // MARK: - Props
    
    private lazy var image = standartImage
    var selectedMeasurment = 0
    var count = 0
    var isFavorite = false
    
    // MARK: - Initializations
    init(from menuItemJSON: MenuItemJSON) {

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
        super.init(category: "category",
                   name: "name",
                   prices: [0],
                   measurements: [""],
                   imageName: "imageName",
                   description: "description")
    }
    
    override init(category: String, name: String, prices: [Int], measurements: [String], imageName: String, description: String) {
        super.init(category: category,
                   name: name,
                   prices: prices,
                   measurements: measurements,
                   imageName: imageName,
                   description: description)
    }
    
    init(item: MenuItem) {
        self.selectedMeasurment = item.selectedMeasurment
        self.count = item.count
        self.isFavorite = item.isFavorite
        super.init(category: item.category,
                   name: item.name,
                   prices: item.prices,
                   measurements: item.measurements,
                   imageName: item.imageName,
                   description: item.description)
        
        self.image = item.image
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func setImage(type: PhotoType, completion: @escaping (UIImage) -> ()) {
        guard self.imageName != ""  else { completion(standartImage); return }
        
        var currentImageName = self.imageName
        if type == .cellPhoto { currentImageName += "CELL" }
        
        guard self.image == standartImage else { completion(self.image); return }
        if let assetsImage = UIImage(named: currentImageName) {
            if type == .detailPhoto { self.image = assetsImage }
            completion(assetsImage)
        } else {
            NetworkManager.fetchImage(PhotoFolder.item, self.imageName) { image in
                if type == .detailPhoto { self.image = image }
                completion(image)
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

enum PhotoType {
    case detailPhoto
    case cellPhoto
}
