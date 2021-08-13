//
//  CakeModel.swift
//  Flan
//
//  Created by Вадим on 22.05.2021.
//

import UIKit

class Cake: CakeJSON {
    
    private let standartImage = UIImage(named: "Standart image.jpg")!
    
    // MARK: - Props
    
    let number: Int
    private var image: UIImage
    
    // MARK: - Initialization
    
    init(number: Int, imageName: String) {
        self.number = number
        self.image = standartImage
        super.init(imageName: imageName)
    }
    
    init() {
        self.number = 0
        self.image = standartImage
        super.init(imageName: "standartImage")
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
            NetworkManager.fetchImage(PhotoFolder.cake, self.imageName) { image in
                self.image = image
                completion(self.image)
            }
        }
    }
    
    func getImage() -> UIImage {
        return image
    }
}

class CakeJSON: Decodable {
    let imageName: String
    
    init(imageName: String) {
        self.imageName = imageName
    }
}
