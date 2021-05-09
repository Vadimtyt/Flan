//
//  MenuCell.swift
//  Flan
//
//  Created by Вадим on 02.04.2021.
//

import UIKit

protocol MenuVCDelegate: class {
    func updateListBadge()
}

protocol FavoriteVCDelegate: class {
    func updateListBadge()
    func updateFavoriteVC()
}

class MenuCell: UITableViewCell {
    
    let indexOfListVC = 2
    
    weak var MenuVCDelegate: MenuVCDelegate?
    weak var FavoriteVCDelegate: FavoriteVCDelegate?
    
    static let reuseId = "MenuCell"
    var item: MenuItem = MenuItem(name: "Имя", price: 0)
    
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
        MenuVCDelegate?.updateListBadge()
        FavoriteVCDelegate?.updateListBadge()
    }
    
    func updateFavoriteVC() {
        FavoriteVCDelegate?.updateListBadge()
        FavoriteVCDelegate?.updateFavoriteVC()
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
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
        TapticFeedback.shared.tapticFeedback(.light)
        
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
        TapticFeedback.shared.tapticFeedback(.light)
        
        item.isFavorite = !item.isFavorite
        
        if item.isFavorite == true {
            ListOfMenuItems.shared.updateFavorites()
        } else {
            if FavoriteVCDelegate == nil { ListOfMenuItems.shared.updateFavorites() }
        }
        
        
        if item.isFavorite == true {
            favoriteButton.setImage(UIImage(named: "favorite"), for: .normal)
        } else { favoriteButton.setImage(UIImage(named: "addToFavorite"), for: .normal) }
        
        updateFavoriteVC()
    }
}

