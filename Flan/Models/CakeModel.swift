//
//  CakeModel.swift
//  Flan
//
//  Created by Вадим on 22.05.2021.
//

import UIKit

class Cake: CakeJSON {
    
    // MARK: - Props
    
    let number: Int
    let imageModel = ImageModel()
    
    // MARK: - Initialization
    
    init(number: Int, imageName: String) {
        self.number = number
        super.init(imageName: imageName)
    }
    
    init() {
        self.number = 0
        super.init(imageName: "standartImage")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func setImage(size: CGSize, type: PhotoType, completion: @escaping (UIImage) -> ()) {
        imageModel.prepareImage(size: size, type: type, imageName: imageName) { image in
            completion(image)
        }
    }
    
    func getImage(type: PhotoType) -> UIImage {
        switch type {
        case .cellPhoto:
            return imageModel.cellImage
        case .detailPhoto:
            return imageModel.detailImage
        }
    }
}

class CakeJSON: Decodable {
    let imageName: String
    
    init(imageName: String) {
        self.imageName = imageName
    }
}
