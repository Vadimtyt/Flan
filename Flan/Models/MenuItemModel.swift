//
//  MenuItemModel.swift
//  Flan
//
//  Created by Вадим on 22.03.2021.
//

import UIKit

class MenuItem: MenuItemJSON {
    
    static let standartImage = UIImage(named: "Standart image.jpg")!
    
    // MARK: - Props

    private lazy var cellImage = MenuItem.standartImage
    private lazy var detailImage = MenuItem.standartImage
    
    // MARK: - Initializations
    init(menuItemJSON: MenuItemJSON) {

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
    
    override init(menuItem: MenuItem) {
        super.init(category: menuItem.category,
                   name: menuItem.name,
                   prices: menuItem.prices,
                   measurements: menuItem.measurements,
                   imageName: menuItem.imageName,
                   description: menuItem.description)
        
        self.cellImage = menuItem.cellImage
        self.detailImage = menuItem.detailImage
        self.selectedMeasurment = menuItem.selectedMeasurment
        self.count = menuItem.count
        self.isFavorite = menuItem.isFavorite
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    
    func setImage(type: PhotoType, completion: @escaping (UIImage) -> ()) {
        guard self.imageName != ""  else { completion(MenuItem.standartImage); return }
        
        var currentImageName = self.imageName
        if type == .cellPhoto { currentImageName += "CELL" }
        
        guard self.detailImage == MenuItem.standartImage else { completion(self.detailImage); return }
        if let assetsImage = UIImage(named: currentImageName) {
            switch type {
            case .cellPhoto:
                self.detailImage = assetsImage;
            case .detailPhoto:
                self.cellImage = assetsImage
            }
            completion(assetsImage)
        } else {
            NetworkManager.fetchImage(PhotoFolder.item, self.imageName) { image in
                self.detailImage = image
                completion(image)
            }
        }
    }
}

class MenuItemJSON: Codable {
    let category: String
    let name: String
    var prices: [Int]
    var measurements: [String]
    var imageName: String
    var description: String
    
    lazy var selectedMeasurment = 0
    lazy var count = 0
    lazy var isFavorite = false
    
    init(category: String, name: String, prices: [Int], measurements: [String], imageName: String, description: String) {
        self.category = category
        self.name = name
        self.prices = prices
        self.measurements = measurements
        self.imageName = imageName
        self.description = description
    }
    
    init(menuItem: MenuItem) {
        self.category = menuItem.category
        self.name = menuItem.name
        self.prices = menuItem.prices
        self.measurements = menuItem.measurements
        self.imageName = menuItem.imageName
        self.description = menuItem.description
        
        self.selectedMeasurment = menuItem.selectedMeasurment
        self.count = menuItem.count
        self.isFavorite = menuItem.isFavorite
    }
}

enum PhotoType {
    case detailPhoto
    case cellPhoto
}
