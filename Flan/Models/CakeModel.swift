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
    
    func setImage(size: CGSize?, completion: @escaping (UIImage?, Bool) -> ()) {
        let isNeedAnimation = !(imageModel.detailImage != nil && imageModel.detailImage != ImageModel.standartImage)
        imageModel.loadImage(type: .detailPhoto, folder: .forCakes, imageName: imageName, size: size) { [isNeedAnimation] image  in
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
