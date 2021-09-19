//
//  ImageModel.swift
//  Flan
//
//  Created by Вадим on 10.09.2021.
//

import UIKit

class ImageModel {
    
    static let standartImage = UIImage(named: "Standart image.jpg")!
    
    // MARK: - Props

    var cellImage: UIImage
    var detailImage: UIImage
    var isCellImageSet: Bool { return self.cellImage != ImageModel.standartImage}
    
    init() {
        cellImage = ImageModel.standartImage
        detailImage = ImageModel.standartImage
    }
    
    init(from imageModel: ImageModel) {
        self.cellImage = imageModel.cellImage
        self.detailImage = imageModel.detailImage
    }
    
    func prepareImage(size: CGSize, type: PhotoType, imageName: String, completion: @escaping (UIImage) -> ()) {
        guard imageName != ""  else { completion(ImageModel.standartImage); return }
        
        if type == .cellPhoto && cellImage != ImageModel.standartImage {
            completion(cellImage)
            return
        }
        
        if type == .detailPhoto && detailImage != ImageModel.standartImage {
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
            NetworkManager.fetchImage(PhotoFolder.item, imageName) { image in
                if image == ImageModel.standartImage {
                    self.cellImage = image
                    self.detailImage = image
                    completion(image)
                    return
                }
                
                switch type {
                case .cellPhoto:
                    self.detailImage = image
                    DispatchQueue.global(qos: .userInitiated).async {
                        let resizedImage = image.resized(to: size)
                        self.cellImage = resizedImage
                        completion(resizedImage)
                    }
                case .detailPhoto:
                    self.detailImage = image
                    completion(image)
                }
            }
        }
    }
}
