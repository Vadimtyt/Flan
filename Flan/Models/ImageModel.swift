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

    private var cellImage: UIImage?
    private var detailImage: UIImage?
    
    var isCellImageSet: Bool {
        return ((self.cellImage != ImageModel.standartImage) && (self.cellImage != nil))
    }
    var isDetailImageSet: Bool {
        return ((self.detailImage != ImageModel.standartImage) && (self.detailImage != nil))
    }
    
    // MARK: - Initialization
    
    init() { }
    
    init(from imageModel: ImageModel) {
        self.cellImage = imageModel.cellImage
        self.detailImage = imageModel.detailImage
    }
    
    // MARK: - Funcs
    
    func loadImage(type: PhotoType, folder: PhotoFolder, imageName: String, size: CGSize?, completion: @escaping (UIImage?) -> ()) {
        guard imageName != ""  else { completion(ImageModel.standartImage); return }
        
        if (type == .cellPhoto && cellImage != nil) || (type == .detailPhoto && detailImage != nil) {
            switch type {
            case .cellPhoto:
                completion(cellImage)
            case .detailPhoto:
                completion(detailImage)
            }
            return
        }

        if let assetsImage = UIImage(named: imageName) {
            resizeIfNeeded(image: assetsImage, type: type, size: size) { (image) in
                completion(image)
            }
        } else {
            downloadNewtworkImage(from: folder, by: imageName) { [weak self] (image) in
                guard image != ImageModel.standartImage else { completion(image); return }
                
                self?.detailImage = image
                self?.resizeIfNeeded(image: image, type: type, size: size) { image in
                    completion(image)
                }
            }
        }
    }
    
    private func resizeIfNeeded(image: UIImage, type: PhotoType, size: CGSize?, completion: @escaping (UIImage?) -> ()) {
        guard type == .cellPhoto, let size = size else {
            detailImage = image
            completion(image)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.cellImage = image.resized(to: size)
            completion(self?.cellImage)
        }
    }
    
    private func downloadNewtworkImage(from folder: PhotoFolder, by imageName: String, completion: @escaping (UIImage) -> ()) {
        NetworkManager.fetchImage(from: folder, by: imageName) { (image) in
            completion(image)
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
