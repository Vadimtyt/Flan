//
//  ListCell.swift
//  Flan
//
//  Created by Вадим on 07.04.2021.
//

import UIKit

protocol updatingListCell: class {
    func updateList()
    func updateListBadge()
}

class ListCell: UITableViewCell {
    
    weak var listDelegate: updatingListCell?
    
    static let reuseId = "ListCell"
    var item: MenuItem = MenuItem(name: "Имя", price: 0)
    
    @IBOutlet weak var imageItemView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var countItemLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(with item: MenuItem) {
        self.item = item
        
        if item.count > 0 {
            removeButton.isHidden = false
            countItemLabel.isHidden = false
            countItemLabel.text = "\(item.count)"
        }
        
        imageItemView.image = item.image
        nameLabel.text = item.name
        priceLabel.text = "\(item.price)Р"
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        self.item.count -= 1
        countItemLabel.text = "\(self.item.count)"
        if self.item.count == 0 {
            ListOfMenuItems.shared.removeFromList(item: self.item)
        }
        
        self.listDelegate?.updateList()
        self.listDelegate?.updateListBadge()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        self.item.count += 1
        countItemLabel.text = "\(self.item.count)"
        
        self.listDelegate?.updateList()
        self.listDelegate?.updateListBadge()
    }
}
