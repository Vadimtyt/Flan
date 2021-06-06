//
//  MenuDetailVC.swift
//  Flan
//
//  Created by Вадим on 01.06.2021.
//

import UIKit

class MenuDetailVC: UIViewController {
    
    var item: MenuItem!
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemImage.image = item.image
        nameLabel.text = item.name
        priceLabel.text = "\(item.price)"
    }
}
