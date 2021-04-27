//
//  ListCell.swift
//  Flan
//
//  Created by Вадим on 07.04.2021.
//

import UIKit

protocol updateListCell: class {
    func updateTableView()
}

class ListCell: UITableViewCell {
    
    weak var delegate: updateListCell?
    
    
    let indexOfListVC = 2
    
    static let reuseId = "ListCell"
    var item: MenuItem = MenuItem(name: "Имя", price: 0)
    var viewController: UIViewController?
    
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
            countItemsLabel.text = "\(self.item.count)"
            ListOfMenuItems.shared.removeFromList(item: self.item)
            
            removeButton.isHidden = true
            countItemsLabel.isHidden = true
        } else if itemsCount > 1 {
            self.item.count -= 1
            countItemsLabel.text = "\(self.item.count)"
        } else { print("ошибка в countItemsLabel") }
        
        updateListVCBadge()
        self.delegate?.updateTableView()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let itemsCount = self.item.count
        
        if itemsCount == 0 {
            self.item.count += 1
            countItemsLabel.text = "\(self.item.count)"
            ListOfMenuItems.shared.addToList(item: item)
            
            removeButton.isHidden = false
            countItemsLabel.isHidden = false
        } else if itemsCount > 0 {
            self.item.count += 1
            countItemsLabel.text = "\(self.item.count)"
        } else { print("ошибка в countItemsLabel") }
        
        updateListVCBadge()
        self.delegate?.updateTableView()
    }
}
