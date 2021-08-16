//
//  MenuDetailVC.swift
//  Flan
//
//  Created by Вадим on 01.06.2021.
//

import UIKit

protocol UpdatingMenuDetailDelegate: UpdatingMenuCellDelegate {
    func updateCellAt(indexPath: IndexPath)
}

class MenuDetailVC: UIViewController {
    
    // MARK: - Props
    
    var item = MenuItem()
    var indexPath: IndexPath!
    weak var updateCellDelegate: UpdatingMenuDetailDelegate?
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var itemImage: UIImageView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var measurmentLabel: UILabel!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var removeButton: UIButton!
    @IBOutlet private weak var countItemLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    
    @IBOutlet private weak var nameView: UIView!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var priceAndCountView: UIView!
    
    @IBOutlet private weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var bottomViewIdent: NSLayoutConstraint!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(MenuDetailVC.tapFunction))
        countItemLabel.isUserInteractionEnabled = true
        countItemLabel.addGestureRecognizer(tap)
        
        if #available(iOS 13.0, *) { closeButton.isHidden = true }
        
        if item.isFavorite {
            favoriteButton.setImage(UIImage(named: "heart.fill.png"), for: .normal)
        } else { favoriteButton.setImage(UIImage(named: "heart.png"), for: .normal) }
        
        setPhoto()
        nameLabel.text = item.name
        descriptionLabel.text = item.description
        priceLabel.text = "\(item.prices[item.selectedMeasurment])Р"
        measurmentLabel.text = item.measurements[item.selectedMeasurment]
        
        if item.measurements.count > 1 {
            configureSegmentedControl()
        } else { segmentedControl.isHidden = true }
        
        countItemLabel.text = "\(item.count)"
        
        if item.count == 0 {
            removeButton.isEnabled = false
        } else if item.count == 99 {
            addButton.isEnabled = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        setupViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if item.count == 0 { item.selectedMeasurment = 0 }
    }
    
    // MARK: - @objc funcs
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    @objc private func tapFunction(sender:UITapGestureRecognizer) {
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
    
    // MARK: - Funcs
    
    private func setupViews() {
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
        removeButton.layer.cornerRadius = 16
        addButton.layer.cornerRadius = 16
    }
    
    private func configureSegmentedControl() {
        segmentedControl.removeAllSegments()
        for index in 0..<item.measurements.count {
            segmentedControl.insertSegment(withTitle: item.measurements[index], at: index, animated: true)
        }
        
        segmentedControl.selectedSegmentIndex = item.selectedMeasurment
    }
    
    private func setPhoto() {
        item.setImage(type: PhotoType.detailPhoto) { image in
            self.itemImage.image = image
        }
    }
    
    // MARK: - @IBAction
    
    @IBAction private func favoriteButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        animatePressingView(sender)
        
        item.isFavorite = !item.isFavorite
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            if self?.item.isFavorite == true {
                self?.favoriteButton.setImage(UIImage(named: "heart.fill.png"), for: .normal)
            } else if self?.item.isFavorite == false { self?.favoriteButton.setImage(UIImage(named: "heart.png"), for: .normal) }
        }
        
        updateCellDelegate?.updateCellAt(indexPath: indexPath)
        updateCellDelegate?.updateFavorites()
    }
    
    @IBAction private func removeButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        self.item.count -= 1
        countItemLabel.text = "\(self.item.count)"
        let itemsCount = self.item.count
        
        if itemsCount == 1 {
            DataManager.shared.removeFromList(item: self.item)
            removeButton.isEnabled = false
        } else if itemsCount == 98{
            addButton.isEnabled = true
        }
        
        removeButton.backgroundColor = .yellow
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.removeButton.backgroundColor = nil
        }
        
        updateCellDelegate?.updateListVCBadge()
        updateCellDelegate?.updateCellAt(indexPath: indexPath)
    }
    
    @IBAction private func addButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        self.item.count += 1
        countItemLabel.text = "\(self.item.count)"
        let itemsCount = self.item.count
        
        if itemsCount == 1 {
            DataManager.shared.addToList(item: item)
            removeButton.isEnabled = true
        } else if itemsCount == 99 {
            addButton.isEnabled = false
        }
        
        addButton.backgroundColor = .yellow
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.addButton.backgroundColor = nil
        }
        
        updateCellDelegate?.updateListVCBadge()
        updateCellDelegate?.updateCellAt(indexPath: indexPath)
    }
    
    
    @IBAction private func segmentedControlChanged(_ sender: UISegmentedControl) {
        TapticFeedback.shared.tapticFeedback(.light)
        let index = sender.selectedSegmentIndex
        item.selectedMeasurment = index
        priceLabel.text = "\(item.prices[index])Р"
        measurmentLabel.text = item.measurements[index]
        
        DataManager.shared.removeFromList(item: item)
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

// MARK: Updating MenuDetailVC delegate

extension MenuDetailVC: UpdatingMenuDetailVCDelegate {
    
    func updateCell(with itemCount: Int) {
        item.count = itemCount
        countItemLabel.text = "\(itemCount)"
        if itemCount == 0 {
            removeButton.isEnabled = false
            addButton.isEnabled = true
            DataManager.shared.removeFromList(item: item)
        } else if itemCount > 0 && itemCount < 99 {
            removeButton.isEnabled = true
            addButton.isEnabled = true
            DataManager.shared.addToList(item: item)
        } else if itemCount == 99 {
            removeButton.isEnabled = true
            addButton.isEnabled = false
            DataManager.shared.addToList(item: item)
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
