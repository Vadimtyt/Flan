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
    private var cakeImage: UIImage? {
        get {
            return cakeImageView.image
        }
        
        set {
            setCakeImage(with: newValue)
        }
    }
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var cakeImageView: UIImageView!
    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    
    // MARK: - Funcs
    
    func configureWith(cake: Cake) {
        self.cake = cake
        setPhoto()
        
        cakeImageView.contentMode = .scaleAspectFill
        roundCorners(.allCorners, radius: 20)
    }
    
    private func setPhoto() {
        downloadIndicator.isHidden = true
        var isSetPhoto = false
        cakeImage = nil
        
        let settingImageName = cake.imageName
        //let imageSize = getImageSize()
        cake.setImage(size: nil) { [settingImageName] image, isNeedAnimation in
            DispatchQueue.main.async {
                guard settingImageName == (self.cake.imageName) && !isSetPhoto else { return }
                self.cakeImage = image
                isSetPhoto = true
                
                guard isNeedAnimation else { return }
                self.cakeImageView.alpha = 0
                UIView.animate(withDuration: 0.2) {
                    self.cakeImageView.alpha = 1
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            if !isSetPhoto {
                self?.downloadIndicator.isHidden = false
                self?.downloadIndicator.startAnimating()
            } else {
                self?.downloadIndicator.stopAnimating()
                self?.downloadIndicator.isHidden = true
            }
        }
    }
    
    private func setCakeImage(with newImage: UIImage?) {
        downloadIndicator.stopAnimating()
        downloadIndicator.isHidden = true
        cakeImageView.image = newImage
    }
    
    override func prepareForReuse() {
        cakeImage = nil
    }
}
