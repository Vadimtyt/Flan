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
    
    init(cakeJSON: CakeJSON) {
        super.init(name: cakeJSON.name, imageName: cakeJSON.imageName)
    }
    
    init() {
        super.init(name: "Название", imageName: "standartImage")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func setImage(completion: @escaping (UIImage?, Bool) -> ()) {
        let isNeedAnimation = !(self.imageModel.isDetailImageSet)
        imageModel.loadImage(type: .detailPhoto, folder: .forCakes, imageName: imageName, size: nil) { [isNeedAnimation] (image) in
            completion(image, isNeedAnimation)
        }
    }
    
    func getImage() -> UIImage? {
        imageModel.getImage(type: .detailPhoto)
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
