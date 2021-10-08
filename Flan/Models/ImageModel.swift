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

    var cellImage: UIImage?
    var detailImage: UIImage?
    var isCellImageSet: Bool {
        return ((self.cellImage != ImageModel.standartImage) && (self.cellImage != nil))
    }
    
    init() { }
    
    init(from imageModel: ImageModel) {
        self.cellImage = imageModel.cellImage
        self.detailImage = imageModel.detailImage
    }
    
    func loadImage(type: PhotoType, folder: PhotoFolder, imageName: String, size: CGSize?, completion: @escaping (UIImage?) -> ()) {
        guard imageName != ""  else { completion(ImageModel.standartImage); return }
        
        if type == .cellPhoto && cellImage != nil {
            completion(cellImage)
            return
        }
        
        if type == .detailPhoto && detailImage != nil {
            completion(detailImage)
            return
        }

        if let assetsImage = UIImage(named: imageName) {
            resizeIfNeeded(image: assetsImage, size: size, type: type) { image in
                completion(image)
            }
        } else {
            NetworkManager.fetchImage(folder, imageName) { [size, type, weak self] image in
                if image == ImageModel.standartImage {
                    completion(image)
                    return
                }
                
                self?.detailImage = image
                self?.resizeIfNeeded(image: image, size: size, type: type) { image in
                    completion(image)
                }
            }
        }
    }
    
    private func resizeIfNeeded(image: UIImage, size: CGSize?, type: PhotoType, completion: @escaping (UIImage?) -> ()) {
        switch type {
        case .cellPhoto:
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let size = size {
                    self?.cellImage = image.resized(to: size)
                } else {
                    self?.cellImage = image
                }
                completion(self?.cellImage)
            }
        case .detailPhoto:
            detailImage = image
            completion(detailImage)
        }
    }
    
    func getImage(type: PhotoType) -> UIImage? {
        switch type {
        case .cellPhoto:
            return cellImage
        case .detailPhoto:
            return detailImage
        }
    }
}
