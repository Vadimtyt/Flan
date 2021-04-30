//
//  MenuCell.swift
//  Flan
//
//  Created by Вадим on 02.04.2021.
//

import UIKit

class MenuCell: UITableViewCell {
    
    let indexOfListVC = 2
    
    static let reuseId = "MenuCell"
    var item: MenuItem = MenuItem(name: "Имя", price: 0)
    var viewController: UITableViewController?
    
    @IBOutlet weak var imageItemView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var countItemLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(with item: MenuItem) {
        self.item = item
        
        if item.count == 0 {
            removeButton.isHidden = true
            countItemLabel.isHidden = true
            countItemLabel.text = "0"
        } else {
            removeButton.isHidden = false
            countItemLabel.isHidden = false
            countItemLabel.text = "\(item.count)"
        }
        
        imageItemView.image = item.image
        nameLabel.text = item.name
        priceLabel.text = "\(item.price)Р"
        if item.isFavorite == true {
            favoriteButton.setImage(UIImage(named: "favorite"), for: .normal)
        } else { favoriteButton.setImage(UIImage(named: "addToFavorite"), for: .normal) }
    }
    
    func updateListVCBadge() {
        let items = ListOfMenuItems.shared.items
        var sumCountOfItems = 0
        
        for item in items {
            if item.count != 0 {
                sumCountOfItems += item.count
            }
        }
        
        if sumCountOfItems != 0 {
            viewController?.navigationController?.tabBarController?.tabBar.items?[indexOfListVC].badgeValue = "\(sumCountOfItems)"
        } else if sumCountOfItems == 0 {
            viewController?.navigationController?.tabBarController?.tabBar.items?[indexOfListVC].badgeValue = nil
        }
        
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        let itemsCount = self.item.count
        
        if itemsCount == 1 {
            self.item.count = 0
            countItemLabel.text = "\(self.item.count)"
            ListOfMenuItems.shared.removeFromList(item: self.item)
            
            removeButton.isHidden = true
            countItemLabel.isHidden = true
        } else if itemsCount > 1 {
            self.item.count -= 1
            countItemLabel.text = "\(self.item.count)"
        } else { print("ошибка в countItemsLabel") }
        
        updateListVCBadge()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let itemsCount = self.item.count
        
        if itemsCount == 0 {
            self.item.count += 1
            countItemLabel.text = "\(self.item.count)"
            ListOfMenuItems.shared.addToList(item: item)
            
            removeButton.isHidden = false
            countItemLabel.isHidden = false
        } else if itemsCount > 0 {
            self.item.count += 1
            countItemLabel.text = "\(self.item.count)"
        } else { print("ошибка в countItemsLabel") }
        
        updateListVCBadge()
    }

    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        item.isFavorite = !item.isFavorite
        
        if item.isFavorite == true {
            favoriteButton.setImage(UIImage(named: "favorite"), for: .normal)
        } else { favoriteButton.setImage(UIImage(named: "addToFavorite"), for: .normal) }
    }
}

