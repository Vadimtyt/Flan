//
//  ListCell.swift
//  Flan
//
//  Created by Вадим on 07.04.2021.
//

import UIKit

protocol UpdatingListCellDelegate: class {
    func updateList()
    func updateListBadge()
}

class ListCell: UITableViewCell {
    
    weak var listDelegate: UpdatingListCellDelegate?
    
    static let reuseId = "ListCell"
    var checkmark = false
    var item: MenuItem = MenuItem(name: "Имя", category: "Категория", price: 0, imageName: "Кекс")
    
    @IBOutlet weak var checkmarkButton: UIButton!
    
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
        selectionStyle = .none
        
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
        TapticFeedback.shared.tapticFeedback(.light)
        
        self.item.count -= 1
        countItemLabel.text = "\(self.item.count)"
        
        self.listDelegate?.updateList()
        self.listDelegate?.updateListBadge()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        self.item.count += 1
        countItemLabel.text = "\(self.item.count)"
        
        self.listDelegate?.updateList()
        self.listDelegate?.updateListBadge()
    }
    
    @available(iOS 13.0, *)
    @IBAction func checkmarkButtonPressed(_ sender: UIButton) {
        checkmark = !checkmark
        if checkmark {
            checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else { checkmarkButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
    }
}
