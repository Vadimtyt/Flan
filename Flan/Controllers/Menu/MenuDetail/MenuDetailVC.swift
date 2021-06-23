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
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countItemLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(MenuDetailVC.tapFunction))
        countItemLabel.isUserInteractionEnabled = true
        countItemLabel.addGestureRecognizer(tap)
        
        segmentedControl.isHidden = true
        
        itemImage.image = item.image
        nameLabel.text = item.name
        priceLabel.text = "\(item.prices[item.selectedMeasurment])Р/\("" + item.measurements[item.selectedMeasurment])"
        
        if item.measurements.count > 1 {
            segmentedControl.isHidden = false
            configureSegmentedControl()
        }
        
        countItemLabel.text = "\(item.count)"
        if item.count == 0 {
            removeButton.isEnabled = false
        }
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
    
    func  configureSegmentedControl() {
        segmentedControl.removeAllSegments()
        for index in 0..<item.measurements.count {
            segmentedControl.insertSegment(withTitle: item.measurements[index], at: index, animated: true)
        }
        //if item.count != 0 {
            segmentedControl.selectedSegmentIndex = item.selectedMeasurment
        //} else { segmentedControl.selectedSegmentIndex = 0 }
        
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
        } else if itemsCount > 0 {
            self.item.count += 1
            countItemLabel.text = "\(self.item.count)"
        } else { print("ошибка в countItemsLabel") }
        
        updateCellDelegate?.updateListVCBadge()
        updateCellDelegate?.updateCellAt(indexPath: indexPath)
    }
    
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        item.selectedMeasurment = index
        priceLabel.text = "\(item.prices[index])Р/\("" + item.measurements[index])"
        
        ListOfMenuItems.shared.removeFromList(item: item)
        countItemLabel.text = "\(item.count)"
        removeButton.isEnabled = false
        
        updateCellDelegate?.updateCellAt(indexPath: indexPath)
        updateCellDelegate?.updateListVCBadge()
    }
}

extension MenuDetailVC: UpdatingMenuDetailVCDelegate {

    func update(itemCount: Int) {
        item.count = itemCount
        countItemLabel.text = "\(itemCount)"
        if itemCount != 0 {
            ListOfMenuItems.shared.addToList(item: item)
            removeButton.isEnabled = true
        } else {
            ListOfMenuItems.shared.removeFromList(item: self.item)
            removeButton.isEnabled = false
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
