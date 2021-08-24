//
//  CakeModel.swift
//  Flan
//
//  Created by Вадим on 22.05.2021.
//

import UIKit

class Cake: CakeJSON {
    
    static let standartImage = UIImage(named: "Standart image.jpg")!
    
    // MARK: - Props
    
    let number: Int
    private var image: UIImage
    
    // MARK: - Initialization
    
    init(number: Int, imageName: String) {
        self.number = number
        self.image = Cake.standartImage
        super.init(imageName: imageName)
    }
    
    init() {
        self.number = 0
        self.image = Cake.standartImage
        super.init(imageName: "standartImage")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func setImage(completion: @escaping (UIImage) -> ()) {
        guard image == Cake.standartImage else { completion(image); return }
        if let assetsImage = UIImage(named: imageName) {
            image = assetsImage
            completion(image)
        } else {
            NetworkManager.fetchImage(PhotoFolder.cake, imageName) { [weak self] image in
                self?.image = image
                completion(image)
            }
        }
    }
    
    func getImage() -> UIImage { image }
}

class CakeJSON: Decodable {
    let imageName: String
    
    init(imageName: String) {
        self.imageName = imageName
    }
}
