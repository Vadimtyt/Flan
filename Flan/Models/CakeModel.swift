//
//  CakeModel.swift
//  Flan
//
//  Created by Вадим on 22.05.2021.
//

import UIKit

class Cake: CakeJSON {
    
    // MARK: - Props
    
    let imageModel = ImageModel()
    
    // MARK: - Initialization
    
    override init(name: String, imageName: String) {
        super.init(name: name, imageName: imageName)
    }
    
    init() {
        super.init(name: "Название", imageName: "standartImage")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func setImage(size: CGSize, type: PhotoType, completion: @escaping (UIImage, Bool) -> ()) {
        let isNeedAnimation = !(self.imageModel.isCellImageSet)
        imageModel.prepareImage(size: size, type: type, folder: .forCakes, imageName: imageName) { [isNeedAnimation] image  in
            completion(image, isNeedAnimation)
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
    let name: String
    let imageName: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}
