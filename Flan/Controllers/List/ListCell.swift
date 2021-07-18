//
//  ListCell.swift
//  Flan
//
//  Created by Вадим on 07.04.2021.
//

import UIKit

protocol UpdatingListCellDelegate: AnyObject {
    func updateList()
    func updateListBadge()
    func addToCompleted(item: MenuItem)
    func removeFromCompleted(completedItem: MenuItem)
}

class ListCell: UITableViewCell {
    
    weak var listDelegate: UpdatingListCellDelegate?
    
    static let reuseId = "ListCell"
    var checkmark = false
    var item: MenuItem = MenuItem(name: "Имя", category: "Категория", prices: [0], measurements: [""], imageName: "Кекс")
    
    @IBOutlet weak var checkmarkButton: UIButton!
    
//    @IBOutlet weak var imageItemView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var countItemLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(with item: MenuItem, isCompleted: Bool, listDelegate: UpdatingListCellDelegate) {
        self.item = item
        selectionStyle = .none
        
        if item.count > 0 {
            removeButton.isHidden = false
            countItemLabel.isHidden = false
        }
        if item.count >= 99 {
            item.count = 99
            addButton.isEnabled = false
        }
        
//        imageItemView.image = item.image
        nameLabel.text = item.name
        priceLabel.text = "\(item.prices[item.selectedMeasurment])Р/\(item.measurements[item.selectedMeasurment])"
        countItemLabel.text = "\(item.count)"
        
        self.checkmark = isCompleted
        if #available(iOS 13.0, *) {
            if checkmark {
                removeButton.isEnabled = false
                addButton.isEnabled = false
//                imageItemView.alpha = 0.7
                checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            } else {
                removeButton.isEnabled = true
                addButton.isEnabled = true
//                imageItemView.alpha = 1
                checkmarkButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            }
        }
        
        self.listDelegate = listDelegate
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
         self.item.count -= 1
        if self.item.count < 99  {
            addButton.isEnabled = true
        }
        countItemLabel.text = "\(self.item.count)"
        
        self.listDelegate?.updateList()
        self.listDelegate?.updateListBadge()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        self.item.count += 1
        if self.item.count == 99 {
            addButton.isEnabled = false
        }
        countItemLabel.text = "\(self.item.count)"
        
        self.listDelegate?.updateList()
        self.listDelegate?.updateListBadge()
    }
    
    @available(iOS 13.0, *)
    @IBAction func checkmarkButtonPressed(_ sender: UIButton) {
        checkmark = !checkmark
        if checkmark {
            checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            listDelegate?.addToCompleted(item: item)
        } else {
            checkmarkButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            listDelegate?.removeFromCompleted(completedItem: item)
        }
    }
}
