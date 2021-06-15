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
        
        itemImage.image = item.image
        nameLabel.text = item.name
        priceLabel.text = "\(item.price)Р"
        
        countItemLabel.text = "\(item.count)"
        if item.count == 0 {
            countItemLabel.isHidden = true
            removeButton.isHidden = true
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
        updateCellDelegate?.updateCellAt(indexPath: indexPath)
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
        updateCellDelegate?.updateCellAt(indexPath: indexPath)
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

extension MenuDetailVC: UpdatingMenuDetailVCDelegate {

    func update(itemCount: Int) {
        item.count = itemCount
        countItemLabel.text = "\(itemCount)"
        updateCellDelegate?.updateListVCBadge()
        updateCellDelegate?.updateCellAt(indexPath: indexPath)
    }
}

extension MenuDetailVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
