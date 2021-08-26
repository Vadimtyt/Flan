//
//  CustomizedCell.swift
//  Flan
//
//  Created by Вадим on 21.05.2021.
//

import UIKit

class CustomizedCell: UICollectionViewCell {

    // MARK: - Props
    
    private var cake = Cake()
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var cakeImage: UIImageView!
    
    // MARK: - Funcs
    
    func configureWith(cake: Cake) {
        self.cake = cake
        setPhoto()
        
        cakeImage.contentMode = .scaleAspectFill
        self.backgroundColor = .red
        roundCorners(.allCorners, radius: 20)
    }
    
    private func setPhoto() {
        cakeImage.image = Cake.standartImage
        
        let settingImageName = cake.imageName
        let imageSize = CGSize(width: cakeImage.bounds.width, height: cakeImage.bounds.height)
        cake.setImage(size: imageSize, type: .cellPhoto) { [settingImageName] image in
            DispatchQueue.main.async {
                if settingImageName == (self.cake.imageName) {
                    self.cakeImage.image = image
                }
            }
        }
    }
}
