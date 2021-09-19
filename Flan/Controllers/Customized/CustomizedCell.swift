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
    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    
    // MARK: - Funcs
    
    func configureWith(cake: Cake) {
        self.cake = cake
        setPhoto()
        
        cakeImage.contentMode = .scaleAspectFill
        roundCorners(.allCorners, radius: 20)
    }
    
    private func setPhoto() {
        downloadIndicator.isHidden = true
        var isSetPhoto = false
        cakeImage.image = nil
        
        let settingImageName = cake.imageName
        let imageSize = getImageSize()
        cake.setImage(size: imageSize, type: .cellPhoto) { [settingImageName] image, isNeedAnimation  in
            DispatchQueue.main.async {
                guard settingImageName == (self.cake.imageName) && !isSetPhoto else { return }
                self.cakeImage.image = image
                isSetPhoto = true
                
                if isNeedAnimation {
                    self.cakeImage.alpha = 0
                    UIView.animate(withDuration: 0.2) {
                        self.cakeImage.alpha = 1
                    }
                }

                self.downloadIndicator.stopAnimating()
                self.downloadIndicator.isHidden = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            if !isSetPhoto {
                self?.downloadIndicator.isHidden = false
                self?.downloadIndicator.startAnimating()
            }
        }
    }
    
    private func getImageSize() -> CGSize {
        let scale = UIScreen.main.nativeScale
        let imageSize = CGSize(width: cakeImage.bounds.width * scale, height: cakeImage.bounds.height * scale)
        
        return imageSize
    }
}
