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
    private var cellImage: UIImage
    private var detailImage: UIImage
    
    // MARK: - Initialization
    
    init(number: Int, imageName: String) {
        self.number = number
        self.cellImage = Cake.standartImage
        self.detailImage = Cake.standartImage
        super.init(imageName: imageName)
    }
    
    init() {
        self.number = 0
        self.cellImage = Cake.standartImage
        self.detailImage = Cake.standartImage
        super.init(imageName: "standartImage")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
//    func setImage(type: PhotoType, completion: @escaping (UIImage) -> ()) {
//        guard image == Cake.standartImage else { completion(image); return }
//        if let assetsImage = UIImage(named: imageName) {
//            image = assetsImage
//            completion(image)
//        } else {
//            NetworkManager.fetchImage(PhotoFolder.cake, imageName) { [weak self] image in
//                self?.image = image
//                completion(image)
//            }
//        }
//    }
    
    func setImage(size: CGSize, type: PhotoType, completion: @escaping (UIImage) -> ()) {
        guard imageName != ""  else { completion(Cake.standartImage); return }
        
        if type == .cellPhoto && cellImage != Cake.standartImage {
            completion(cellImage)
            return
        }
        
        if type == .detailPhoto && detailImage != Cake.standartImage {
            completion(detailImage)
            return
        }

        if let assetsImage = UIImage(named: imageName) {
            switch type {
            case .cellPhoto:
                //let size = CGSize(width: 400, height: 300)
                DispatchQueue.global(qos: .userInitiated).async {
                    self.cellImage = assetsImage.resized(to: size)
                    completion(self.cellImage)
                }
            case .detailPhoto:
                detailImage = assetsImage
                completion(assetsImage)
            }
        } else {
            NetworkManager.fetchImage(PhotoFolder.cake, self.imageName) { [weak self] image in
                switch type {
                case .cellPhoto:
                    let size = CGSize(width: 300, height: 300)
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
    
    func getImage(type: PhotoType) -> UIImage {
        switch type {
        case .cellPhoto:
            return cellImage
        case .detailPhoto:
            return detailImage
        }
    }
}

class CakeJSON: Decodable {
    let imageName: String
    
    init(imageName: String) {
        self.imageName = imageName
    }
}
