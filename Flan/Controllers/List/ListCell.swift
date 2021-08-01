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
    var item: MenuItem = MenuItem(name: "Имя", category: "Категория", prices: [0], measurements: [""], imageName: "Кекс", description: "Описание")
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var countItemLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var checkmarkButton: UIButton!
    
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        setupViews()
    }
    
    override func prepareForReuse() {
        resetAll()
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
        
        nameLabel.text = item.name
        priceLabel.text = "\(item.prices[item.selectedMeasurment])Р/\(item.measurements[item.selectedMeasurment])"
        countItemLabel.text = "\(item.count)"
        
        self.checkmark = isCompleted
        if checkmark {
            removeButton.isEnabled = false
            addButton.isEnabled = false
            mainView.alpha = 0.5
            checkmarkButton.setImage(UIImage(named: "checkmark.circle.fill.png"), for: .normal)
        } else {
            removeButton.isEnabled = true
            addButton.isEnabled = true
            mainView.alpha = 1
            checkmarkButton.setImage(UIImage(named: "checkmark.circle.png"), for: .normal)
        }
        
        self.listDelegate = listDelegate
    }
    
    func setupViews() {
        checkmarkButton.layer.cornerRadius = 12
        countItemLabel.layer.borderColor =  UIColor.yellow.cgColor
        countItemLabel.layer.borderWidth = 2.5
        countItemLabel.layer.cornerRadius = 16
        countItemLabel.roundCorners(.allCorners, radius: 16)
        
        removeButton.layer.cornerRadius = 16
        addButton.layer.cornerRadius = 16
    }
    
    func resetAll() {
        checkmarkButton.imageView?.image = nil
        
        nameLabel.text = nil
        priceLabel.text = nil
        countItemLabel.text = nil
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
         self.item.count -= 1
        removeButton.backgroundColor = .yellow
        
        if self.item.count < 99  {
            addButton.isEnabled = true
        }
        countItemLabel.text = "\(self.item.count)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.removeButton.backgroundColor = nil
        }
        
        self.listDelegate?.updateList()
        self.listDelegate?.updateListBadge()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        self.item.count += 1
        addButton.backgroundColor = .yellow
        if self.item.count == 99 {
            addButton.isEnabled = false
        }
        countItemLabel.text = "\(self.item.count)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.addButton.backgroundColor = nil
        }
        
        self.listDelegate?.updateList()
        self.listDelegate?.updateListBadge()
    }
    
    @IBAction func checkmarkButtonPressed(_ sender: UIButton) {
        animatePressingView(sender)
        checkmark = !checkmark
        if checkmark {
            checkmarkButton.setImage(UIImage(named: "checkmark.circle.fill.png"), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.listDelegate?.addToCompleted(item: self!.item)
            }
        } else {
            checkmarkButton.setImage(UIImage(named: "checkmark.circle.png"), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.listDelegate?.removeFromCompleted(completedItem: self!.item)
            }
        }
    }
}
