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
    }
    
    private func setPhoto() {
        cake.setImage { image in
            self.cakeImage.image = image
        }
    }
}
