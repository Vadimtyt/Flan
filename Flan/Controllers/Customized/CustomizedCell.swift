//
//  CustomizedCell.swift
//  Flan
//
//  Created by Вадим on 21.05.2021.
//

import UIKit

class CustomizedCell: UICollectionViewCell {
    
    var cake = Cake(number: 0, image: UIImage.init(named: "Кекс")!)
    
    @IBOutlet weak var cakeImage: UIImageView!
    
    func configureWith(cake: Cake) {
        self.cake = cake
        cakeImage.image = cake.image
        
        cakeImage.contentMode = .scaleAspectFill
        self.backgroundColor = .red
    }
}
