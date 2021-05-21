//
//  CustomizedDetail.swift
//  Flan
//
//  Created by Вадим on 22.05.2021.
//

import UIKit

class CustomizedDetailVC: UIViewController {
    var cake: Cake!
    
    @IBOutlet weak var cakeImage: UIImageView!
    @IBOutlet weak var cakeNumberLabel: UILabel!
    override func viewDidLoad() {
        cakeImage.image = cake.image
        cakeNumberLabel.text = "#\(cake.number)"
    }
    
}

