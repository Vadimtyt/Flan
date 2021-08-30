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
    
    var selectedMeasurment = 0
    var count = 0
    var isFavorite = false
    
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
    
    enum CodingKeys: String, CodingKey {
        case category = "category"
        case name = "name"
        case prices = "prices"
        case measurements = "measurements"
        case imageName = "imageName"
        case description = "description"
        case selectedMeasurment = "selectedMeasurment"
        case count = "count"
        case isFavorite = "isFavorite"
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(category, forKey: .category)
        try container.encode(name, forKey: .name)
        try container.encode(prices, forKey: .prices)
        try container.encode(measurements, forKey: .measurements)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(description, forKey: .description)
        try container.encode(selectedMeasurment, forKey: .selectedMeasurment)
        try container.encode(count, forKey: .count)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let newCategory = try values.decode(String.self, forKey: .category)
        let newName = try values.decode(String.self, forKey: .name)
        let newPrices = try values.decode([Int].self, forKey: .prices)
        let newMeasurements = try values.decode([String].self, forKey: .measurements)
        let newImageName = try values.decode(String.self, forKey: .imageName)
        let newDescription = try values.decode(String.self, forKey: .description)
        let newSelectedMeasurment = try values.decode(Int.self, forKey: .selectedMeasurment)
        let newCount = try values.decode(Int.self, forKey: .count)
        let newIsFavorite = try values.decode(Bool.self, forKey: .isFavorite)
        
        super.init(category: newCategory,
                   name: newName,
                   prices: newPrices,
                   measurements: newMeasurements,
                   imageName: newImageName,
                   description: newDescription)
        selectedMeasurment = newSelectedMeasurment
        count = newCount
        isFavorite = newIsFavorite
    }
    
    // MARK: - Funcs
    
    func setImage(size: CGSize, type: PhotoType, completion: @escaping (UIImage) -> ()) {
        guard imageName != ""  else { completion(MenuItem.standartImage); return }
        
        if type == .cellPhoto && cellImage != MenuItem.standartImage {
            completion(cellImage)
            return
        }
        
        if type == .detailPhoto && detailImage != MenuItem.standartImage {
            completion(detailImage)
            return
        }

        if let assetsImage = UIImage(named: imageName) {
            switch type {
            case .cellPhoto:
                DispatchQueue.global(qos: .userInitiated).async {
                    self.cellImage = assetsImage.resized(to: size)
                    completion(self.cellImage)
                }
            case .detailPhoto:
                detailImage = assetsImage
                completion(assetsImage)
            }
        } else {
            NetworkManager.fetchImage(PhotoFolder.item, self.imageName) { [weak self] image in
                if image == MenuItem.standartImage {
                    self?.cellImage = image
                    self?.detailImage = image
                    completion(image)
                    return
                }
                
                switch type {
                case .cellPhoto:
                    self?.detailImage = image
                    DispatchQueue.global(qos: .userInitiated).async {
                        let resizedImage = image.resized(to: size)
                        self?.cellImage = resizedImage
                        completion(resizedImage)
                    }
                case .detailPhoto:
                    self?.detailImage = image
                    completion(image)
                }
            }
        }
    }
}

class MenuItemJSON: Codable {
    
    // MARK: - Props
    
    let category: String
    let name: String
    var prices: [Int]
    var measurements: [String]
    var imageName: String
    var description: String
    
    // MARK: - Initializations
    
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
    }
}
