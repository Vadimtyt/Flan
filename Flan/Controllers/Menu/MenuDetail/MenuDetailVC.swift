//
//  MenuDetailVC.swift
//  Flan
//
//  Created by Вадим on 01.06.2021.
//

import UIKit

class MenuDetailVC: UIViewController {
    
    var item: MenuItem!
    weak var updateCellDelegate: UpdatingMenuCellDelegate?
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countItemLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemImage.image = item.image
        nameLabel.text = item.name
        priceLabel.text = "\(item.price)Р"
        
        countItemLabel.text = "\(item.count)"
        if item.count == 0 {
            countItemLabel.isHidden = true
            removeButton.isHidden = true
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
        
        updateCellDelegate?.updateListVCBadge()
    }
    
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
            {
            case 0:
                print("first segment selected")
                //by 100g
            case 1:
                print("second segment selected")
                //by count
            default:
                break
            }
    }
}
