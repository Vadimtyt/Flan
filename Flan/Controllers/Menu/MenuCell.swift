//
//  MenuCell.swift
//  Flan
//
//  Created by Вадим on 02.04.2021.
//

import UIKit

protocol UpdatingMenuCellDelegate: AnyObject {
    func updateListVCBadge()
    func updateFavorites()
    func updateCellAt(indexPath: IndexPath)
}

class MenuCell: UITableViewCell {
    
    let indexOfListVC = 2
    
    weak var updateCellDelegate: UpdatingMenuCellDelegate?
    
    static let reuseId = "MenuCell"
    var item: MenuItem = MenuItem(name: "Имя", category: "Категория", prices: [0], measurements: [""], imageName: "Кекс", description: "Описание")
    
    @IBOutlet weak var backgoundSubwiew: UIView!
    @IBOutlet weak var imageItemView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var secondPriceLabel: UILabel!
    @IBOutlet weak var measurmentLabel: UILabel!
    @IBOutlet weak var secondMeasurmentLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var countItemLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var priceLabelWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapPriceLabel = UITapGestureRecognizer(target: self, action: #selector(MenuCell.tapPriceLabel))
        priceLabel.isUserInteractionEnabled = true
        priceLabel.addGestureRecognizer(tapPriceLabel)
        
        let tapSecondPriceLabel = UITapGestureRecognizer(target: self, action: #selector(MenuCell.tapSecondPriceLabel))
        secondPriceLabel.isUserInteractionEnabled = true
        secondPriceLabel.addGestureRecognizer(tapSecondPriceLabel)
    }
    
    override func prepareForReuse() {
        resetAll()
    }
    
    override func layoutSubviews() {
        setupViews()
        setupElements()
    }
    
    func configureCell(with item: MenuItem) {
        self.item = item
    }
    
    func setupViews() {
        
        if UIScreen.main.bounds.width <= 320 { priceLabelWidth.constant = 82 }
        countItemLabel.layer.borderColor =  UIColor.yellow.cgColor
        countItemLabel.layer.borderWidth = 2.5
        countItemLabel.layer.cornerRadius = 16
        priceLabel.layer.borderColor =  UIColor.yellow.cgColor
        priceLabel.layer.borderWidth = 2.5
        priceLabel.layer.cornerRadius = 16
        priceLabel.roundCorners(.allCorners, radius: 16)
        secondPriceLabel.layer.borderColor =  UIColor.yellow.cgColor
        secondPriceLabel.layer.borderWidth = 2.5
        secondPriceLabel.layer.cornerRadius = 16
        backgoundSubwiew.roundCorners([.topRight,.bottomRight], radius: 20)
        imageItemView.roundCorners([.topRight, .bottomRight], radius: 20)
        countItemLabel.roundCorners(.allCorners, radius: 12)
        
        removeButton.layer.cornerRadius = 16
        addButton.layer.cornerRadius = 16
    }
    
    func setupElements() {
        secondPriceLabel.isHidden = true
        secondMeasurmentLabel.isHidden = true
        
        selectionStyle = .none
        
        if item.isFavorite {
            favoriteButton.setImage(UIImage(named: "heart.fill.png"), for: .normal)
        } else { favoriteButton.setImage(UIImage(named: "heart.png"), for: .normal) }
        
        if item.count == 0 {
            removeButton.isEnabled = false
            countItemLabel.text = "0"
            addButton.isEnabled = true
        } else if item.count == 99 {
            removeButton.isEnabled = true
            countItemLabel.text = "\(item.count)"
            addButton.isEnabled = false
        } else {
            removeButton.isEnabled = true
            countItemLabel.text = "\(item.count)"
            addButton.isEnabled = true
        }
        
        imageItemView.image = item.image
        nameLabel.text = item.name
        priceLabel.text = "\(item.prices[0])Р"
        measurmentLabel.text = item.measurements[0]
        updatePriceLabels()
    }
    
    func updatePriceLabels() {
        guard item.prices.count > 1 else { return }
        if item.count == 0 {
            priceLabel.text = "\(item.prices[0])Р"
            measurmentLabel.text = item.measurements[0]
            secondPriceLabel.text = "\(item.prices[1])Р"
            secondMeasurmentLabel.text = item.measurements[1]
            secondPriceLabel.isHidden = false
            secondMeasurmentLabel.isHidden = false
            removeButton.isHidden = true
            countItemLabel.isHidden = true
            addButton.isHidden = true
        } else if item.count > 0 {
            priceLabel.text = "\(item.prices[item.selectedMeasurment])Р"
            measurmentLabel.text = item.measurements[item.selectedMeasurment]
            secondPriceLabel.isHidden = true
            secondMeasurmentLabel.isHidden = true
            removeButton.isHidden = false
            countItemLabel.isHidden = false
            addButton.isHidden = false
        }
    }
    
    func resetAll() {
        imageItemView.image = nil
        nameLabel.text = nil
        favoriteButton.imageView?.image = nil
        priceLabel.text = nil
        secondPriceLabel.text = nil
        measurmentLabel.text = nil
        secondMeasurmentLabel.text = nil
        
        removeButton.isHidden = false
        countItemLabel.isHidden = false
        addButton.isHidden = false
        secondPriceLabel.isHidden = false
    }
    
    @objc func tapPriceLabel(sender:UITapGestureRecognizer) {
        if item.count == 0 {
            item.selectedMeasurment = 0
        }
        secondPriceLabel.isHidden = true
        secondMeasurmentLabel.isHidden = true
        addButtonPressed(addButton)
        
        priceLabel.backgroundColor = .yellow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.priceLabel.backgroundColor = nil
        }
    }
    
    @objc func tapSecondPriceLabel(sender:UITapGestureRecognizer) {
        if item.count == 0 {
            item.selectedMeasurment = 1
        }
        secondPriceLabel.isHidden = true
        secondMeasurmentLabel.isHidden = true
        addButtonPressed(addButton)
        
        priceLabel.backgroundColor = .yellow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.priceLabel.backgroundColor = nil
        }
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let itemsCount = self.item.count
        
        if itemsCount == 1 {
            self.item.count = 0
            countItemLabel.text = "\(self.item.count)"
            ListOfMenuItems.shared.removeFromList(item: self.item)
            
            removeButton.isEnabled = false
            removeButton.backgroundColor = .yellow
        } else if itemsCount > 1 && itemsCount < 100{
            self.item.count -= 1
            countItemLabel.text = "\(self.item.count)"
            addButton.isEnabled = true
            removeButton.backgroundColor = .yellow
        } else { print("ошибка в countItemsLabel") }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.removeButton.backgroundColor = nil
        }
        
        updatePriceLabels()
        updateCellDelegate?.updateListVCBadge()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let itemsCount = self.item.count
        
        if itemsCount == 0 {
            self.item.count += 1
            addButton.backgroundColor = .yellow
            countItemLabel.text = "\(self.item.count)"
            ListOfMenuItems.shared.addToList(item: item)
            
            removeButton.isEnabled = true
        } else if itemsCount > 0 && itemsCount < 98 {
            self.item.count += 1
            addButton.backgroundColor = .yellow
            countItemLabel.text = "\(self.item.count)"
        } else if itemsCount == 98 {
            self.item.count += 1
            addButton.backgroundColor = .yellow
            countItemLabel.text = "\(self.item.count)"
            addButton.isEnabled = false
        } else { print("ошибка в countItemsLabel") }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.addButton.backgroundColor = nil
        }
        
        updatePriceLabels()
        updateCellDelegate?.updateListVCBadge()
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        animatePressingView(sender)

        item.isFavorite = !item.isFavorite

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            if self?.item.isFavorite == true {
                self?.favoriteButton.setImage(UIImage(named: "heart.fill.png"), for: .normal)
            } else if self?.item.isFavorite == false { self?.favoriteButton.setImage(UIImage(named: "heart.png"), for: .normal) }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.updateCellDelegate?.updateFavorites()
            }
        }
    }
}

