//
//  MenuTableCell.swift
//  Flan
//
//  Created by Вадим on 02.04.2021.
//

import UIKit

class MenuTableCell: UITableViewCell {
    
    let indexOfListVC = 2
    
    static let reuseId = "MenuTableCell"
    var item: MenuItem = MenuItem(name: "Имя", price: 0)
    var viewController: UITableViewController?
    
    @IBOutlet weak var imageItemView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var countItemsLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(with item: MenuItem) {
        self.item = item
        
        if item.count == 0 {
            removeButton.isHidden = true
            countItemsLabel.isHidden = true
            countItemsLabel.text = "0"
        } else {
            removeButton.isHidden = false
            countItemsLabel.isHidden = false
            countItemsLabel.text = "\(item.count)"
        }
        
        imageItemView.image = item.image
        nameLabel.text = item.name
        priceLabel.text = "\(item.price)Р"
    }
    
    func updateListVCBadge() {
        let items = ListOfMenuItems.shared.items
        var sumCountOfItems = 0
        
        for item in items {
            if item.count != 0 {
                sumCountOfItems += item.count
            }
        }
        
        viewController?.navigationController?.tabBarController?.tabBar.items?[indexOfListVC].badgeValue = "\(sumCountOfItems)"
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        let itemsCount = self.item.count
        
        if itemsCount == 1 {
            self.item.count = 0
            countItemsLabel.text = "\(self.item.count)"
            
            removeButton.isHidden = true
            countItemsLabel.isHidden = true
        } else if itemsCount > 1 {
            self.item.count -= 1
            countItemsLabel.text = "\(self.item.count)"
        } else { print("ошибка в countItemsLabel") }
        
        updateListVCBadge()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let itemsCount = self.item.count
        
        if itemsCount == 0 {
            self.item.count += 1
            countItemsLabel.text = "\(self.item.count)"
            
            removeButton.isHidden = false
            countItemsLabel.isHidden = false
        } else if itemsCount > 0 {
            self.item.count += 1
            countItemsLabel.text = "\(self.item.count)"
        } else { print("ошибка в countItemsLabel") }
        
        updateListVCBadge()
    }
}

