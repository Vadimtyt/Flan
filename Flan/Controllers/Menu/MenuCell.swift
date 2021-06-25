//
//  MenuCell.swift
//  Flan
//
//  Created by Вадим on 02.04.2021.
//

import UIKit

protocol UpdatingMenuCellDelegate: class {
    func updateListVCBadge()
    func updateFavorites()
    func updateCellAt(indexPath: IndexPath)
}

class MenuCell: UITableViewCell {
    
    let indexOfListVC = 2
    
    weak var updateCellDelegate: UpdatingMenuCellDelegate?
    
    static let reuseId = "MenuCell"
    var item: MenuItem = MenuItem(name: "Имя", category: "Категория", prices: [0], measurements: [""], imageName: "Кекс")
    
    @IBOutlet weak var imageItemView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var secondPriceLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var countItemLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapPriceLabel = UITapGestureRecognizer(target: self, action: #selector(MenuCell.tapPriceLabel))
        priceLabel.isUserInteractionEnabled = true
        priceLabel.addGestureRecognizer(tapPriceLabel)
        
        let tapSecondPriceLabel = UITapGestureRecognizer(target: self, action: #selector(MenuCell.tapSecondPriceLabel))
        secondPriceLabel.isUserInteractionEnabled = true
        secondPriceLabel.addGestureRecognizer(tapSecondPriceLabel)
    }
    
    func configureCell(with item: MenuItem) {
        self.item = item
        secondPriceLabel.isHidden = true
        
        selectionStyle = .none
        
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
        priceLabel.text = "\(item.prices[0])Р/\(item.measurements[0])"
        updatePriceLabels()
        
        if item.isFavorite == true {
            favoriteButton.setImage(UIImage(named: "favorite"), for: .normal)
        } else { favoriteButton.setImage(UIImage(named: "addToFavorite"), for: .normal) }
    }
    
    func updatePriceLabels() {
        if item.prices.count > 1 && item.count == 0 {
            priceLabel.text = "\(item.prices[0])Р/\(item.measurements[0])"
            secondPriceLabel.text = "\(item.prices[1])Р/\(item.measurements[1])"
            secondPriceLabel.isHidden = false
            removeButton.isHidden = true
            countItemLabel.isHidden = true
            addButton.isHidden = true
        } else if item.prices.count > 1 && item.count > 0 {
            priceLabel.text = "\(item.prices[item.selectedMeasurment])Р/\(item.measurements[item.selectedMeasurment])"
            secondPriceLabel.isHidden = true
            removeButton.isHidden = false
            countItemLabel.isHidden = false
            addButton.isHidden = false
        }
    }
    
    @objc func tapPriceLabel(sender:UITapGestureRecognizer) {
        if item.count == 0 {
            item.selectedMeasurment = 0
            removeButton.isHidden = false
            countItemLabel.isHidden = false
            addButton.isHidden = false
            secondPriceLabel.isHidden = true
            addButtonPressed(addButton)
        }
    }
    
    @objc func tapSecondPriceLabel(sender:UITapGestureRecognizer) {
        if item.count == 0 {
            item.selectedMeasurment = 1
            removeButton.isHidden = false
            countItemLabel.isHidden = false
            addButton.isHidden = false
            secondPriceLabel.isHidden = true
            addButtonPressed(addButton)
        }
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
        
        updatePriceLabels()
        updateCellDelegate?.updateListVCBadge()
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
        
        updatePriceLabels()
        updateCellDelegate?.updateListVCBadge()
    }

    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        item.isFavorite = !item.isFavorite
        
        if item.isFavorite == true {
            favoriteButton.setImage(UIImage(named: "favorite"), for: .normal)
        } else { favoriteButton.setImage(UIImage(named: "addToFavorite"), for: .normal) }
        
        updateCellDelegate?.updateFavorites()
    }
}

