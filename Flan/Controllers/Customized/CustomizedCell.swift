//
//  CustomizedCell.swift
//  Flan
//
//  Created by Вадим on 21.05.2021.
//

import UIKit

class CustomizedCell: UICollectionViewCell {

    // MARK: - Props
    
    private var cake = Cake(number: 0, image: UIImage.init(named: "Кекс")!)
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var cakeImage: UIImageView!
    
    // MARK: - Funcs
    
    func configureWith(cake: Cake) {
        self.cake = cake
        cakeImage.image = cake.image
        
        cakeImage.contentMode = .scaleAspectFill
        self.backgroundColor = .red
    }
}
