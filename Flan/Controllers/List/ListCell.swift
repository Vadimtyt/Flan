//
//  ListCell.swift
//  Flan
//
//  Created by Вадим on 07.04.2021.
//

import UIKit

class ListCell: UITableViewCell {
    
    static let reuseId = "ListCell"
    
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
        nameLabel.text = item.name
        priceLabel.text = "\(item.price)Р"
        countItemsLabel.text = "\(item.count)"
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        let itemsCount = Int(countItemsLabel.text ?? "0")!
        
        if itemsCount == 1 {
            countItemsLabel.text = "0"
            
            removeButton.isHidden = true
            countItemsLabel.isHidden = true
        } else if itemsCount > 1 {
            countItemsLabel.text = "\(itemsCount - 1)"
        } else { print("ошибка в countItemsLabel") }
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let itemsCount = Int(countItemsLabel.text ?? "0")!
        
        if itemsCount == 0 {
            countItemsLabel.text = "1"
            
            removeButton.isHidden = false
            countItemsLabel.isHidden = false
        } else if itemsCount > 0 {
            countItemsLabel.text = "\(itemsCount + 1)"
        } else { print("ошибка в countItemsLabel") }
    }
}
