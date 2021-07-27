//
//  MenuDetailVC.swift
//  Flan
//
//  Created by Вадим on 01.06.2021.
//

import UIKit

class MenuDetailVC: UIViewController {
    
    var item: MenuItem!
    var indexPath: IndexPath!
    weak var updateCellDelegate: UpdatingMenuCellDelegate?
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var measurmentLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var countItemLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var priceAndCountView: UIView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomViewIdent: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(MenuDetailVC.tapFunction))
        countItemLabel.isUserInteractionEnabled = true
        countItemLabel.addGestureRecognizer(tap)
        
        segmentedControl.isHidden = true
        if #available(iOS 13.0, *) { closeButton.isHidden = true }
        
        if item.isFavorite {
            favoriteButton.setImage(UIImage(named: "heart.fill.png"), for: .normal)
        } else { favoriteButton.setImage(UIImage(named: "heart.png"), for: .normal) }
        
        itemImage.image = item.image
        nameLabel.text = item.name
        descriptionLabel.text = item.description
        priceLabel.text = "\(item.prices[item.selectedMeasurment])Р"
        measurmentLabel.text = item.measurements[item.selectedMeasurment]
        
        if item.measurements.count > 1 {
            segmentedControl.isHidden = false
            configureSegmentedControl()
        }
        
        countItemLabel.text = "\(item.count)"
        if item.count == 0 {
            removeButton.isEnabled = false
            addButton.isEnabled = true
        } else if item.count > 0 && item.count < 99 {
            removeButton.isEnabled = true
            addButton.isEnabled = true
        } else if item.count == 99 {
            removeButton.isEnabled = true
            addButton.isEnabled = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        setupViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if item.count == 0 { item.selectedMeasurment = 0 }
    }
    
    @objc func doneButtonTapped() {
        view.endEditing(true)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let popoverWidth = 300
        let popoverHeight = 200
        
        let vc = CountPickerPopover(currentCount: item.count, updatingDelegate: self)
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        
        popover.permittedArrowDirections = .down
        vc.preferredContentSize = CGSize(width: popoverWidth, height: popoverHeight)
        
        popover.sourceRect = CGRect(x: countItemLabel.bounds.midX, y: countItemLabel.bounds.minY - 3, width: 0, height: 0)
        popover.delegate = self
        popover.sourceView = countItemLabel
        present(vc, animated: true, completion:nil)
    }
    
    func setupViews() {
        if item.measurements.count < 2 {
            bottomViewHeight.constant = priceAndCountView.bounds.height + 32
        }
        let aspectRatio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
        if aspectRatio <= 16/9 {
            bottomViewIdent.constant = 8
        }
        
        if #available(*, iOS 12.0) { segmentedControl.tintColor = .systemGray }
        
        itemImage.roundCorners([.topLeft, .topRight], radius: 24)
        nameView.roundCorners([.bottomLeft, .bottomRight], radius: 24)
        countItemLabel.layer.borderColor =  UIColor.yellow.cgColor
        countItemLabel.layer.borderWidth = 2.5
        countItemLabel.layer.cornerRadius = 16
        priceLabel.layer.borderColor =  UIColor.yellow.cgColor
        priceLabel.layer.borderWidth = 2.5
        priceLabel.layer.cornerRadius = 16
        bottomView.layer.cornerRadius = 24
        priceAndCountView.layer.cornerRadius = 16
    }
    
    func  configureSegmentedControl() {
        segmentedControl.removeAllSegments()
        for index in 0..<item.measurements.count {
            segmentedControl.insertSegment(withTitle: item.measurements[index], at: index, animated: true)
        }
        
        segmentedControl.selectedSegmentIndex = item.selectedMeasurment
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        item.isFavorite = !item.isFavorite
        
        if item.isFavorite == true {
            favoriteButton.setImage(UIImage(named: "heart.fill.png"), for: .normal)
        } else if item.isFavorite == false { favoriteButton.setImage(UIImage(named: "heart.png"), for: .normal) }
        
        updateCellDelegate?.updateFavorites()
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let itemsCount = self.item.count
        
        if itemsCount == 1 {
            self.item.count = 0
            countItemLabel.text = "\(self.item.count)"
            
            ListOfMenuItems.shared.removeFromList(item: self.item)
            
            removeButton.isEnabled = false
        } else if itemsCount > 1 {
            self.item.count -= 1
            countItemLabel.text = "\(self.item.count)"
        } else { print("ошибка в countItemsLabel") }
        
        updateCellDelegate?.updateListVCBadge()
        updateCellDelegate?.updateCellAt(indexPath: indexPath)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        item.selectedMeasurment = segmentedControl.selectedSegmentIndex
        
        let itemsCount = self.item.count
        
        if itemsCount == 0 {
            self.item.count += 1
            countItemLabel.text = "\(self.item.count)"
            
            ListOfMenuItems.shared.addToList(item: item)
            
            removeButton.isEnabled = true
        } else if itemsCount > 0 && itemsCount < 98{
            self.item.count += 1
            countItemLabel.text = "\(self.item.count)"
        } else if itemsCount == 98 {
            self.item.count += 1
            countItemLabel.text = "\(self.item.count)"
            addButton.isEnabled = false
        } else { print("ошибка в countItemsLabel") }
        
        updateCellDelegate?.updateListVCBadge()
        updateCellDelegate?.updateCellAt(indexPath: indexPath)
    }
    
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        item.selectedMeasurment = index
        priceLabel.text = "\(item.prices[index])Р"
        measurmentLabel.text = item.measurements[index]
        
        ListOfMenuItems.shared.removeFromList(item: item)
        countItemLabel.text = "\(item.count)"
        removeButton.isEnabled = false
        
        updateCellDelegate?.updateCellAt(indexPath: indexPath)
        updateCellDelegate?.updateListVCBadge()
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.medium)
        dismiss(animated: true)
    }
}

extension MenuDetailVC: UpdatingMenuDetailVCDelegate {

    func updateCell(with itemCount: Int) {
        item.count = itemCount
        countItemLabel.text = "\(itemCount)"
        if itemCount == 0 {
            removeButton.isEnabled = false
            addButton.isEnabled = true
            ListOfMenuItems.shared.removeFromList(item: item)
        } else if itemCount > 0 && itemCount < 99 {
            removeButton.isEnabled = true
            addButton.isEnabled = true
            ListOfMenuItems.shared.addToList(item: item)
        } else if itemCount == 99 {
            removeButton.isEnabled = true
            addButton.isEnabled = false
            ListOfMenuItems.shared.addToList(item: item)
        }
        updateCellDelegate?.updateListVCBadge()
        updateCellDelegate?.updateCellAt(indexPath: indexPath)
    }
}

extension MenuDetailVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
