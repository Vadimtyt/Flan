//
//  MenuDetailVC.swift
//  Flan
//
//  Created by Вадим on 01.06.2021.
//

import UIKit

protocol UpdatingMenuDetailVCDelegate: UpdatingMenuCellDelegate {
    func updateCellAt(indexPath: IndexPath?)
}

class MenuDetailVC: UIViewController {
    
    // MARK: - Props
    
    var item = MenuItem()
    var indexPath: IndexPath?
    weak var updateCellDelegate: UpdatingMenuDetailVCDelegate?
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var itemImage: UIImageView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var measurmentLabel: UILabel!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var removeButton: UIButton!
    @IBOutlet private weak var countItemLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    
    
    @IBOutlet private weak var slideIndicatorView: UIView!
    @IBOutlet private weak var nameView: UIView!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var priceAndCountView: UIView!
    
    @IBOutlet private weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var bottomViewBottomIdent: NSLayoutConstraint!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(MenuDetailVC.tapFunction))
        countItemLabel.isUserInteractionEnabled = true
        countItemLabel.addGestureRecognizer(tap)

        setPhoto()
        setupElements()
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
        
        if UIScreen.main.bounds.height <= 568 {
            //For 4-inch display
            bottomViewBottomIdent.constant = 8
        }
        
        if #available(iOS 13.0, *) {
            slideIndicatorView.isHidden = false
        } else {
            slideIndicatorView.isHidden = true
            segmentedControl.tintColor = .systemGray
        }
        
        slideIndicatorView.layer.cornerRadius = 2
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
    
    private func setupElements() {
        if #available(iOS 13.0, *) { closeButton.isHidden = true }
        
        if item.isFavorite {
            favoriteButton.setImage(UIImage(named: "heart.fill.png"), for: .normal)
        } else { favoriteButton.setImage(UIImage(named: "heart.png"), for: .normal) }
        
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
    
    private func configureSegmentedControl() {
        segmentedControl.removeAllSegments()
        for index in 0..<item.measurements.count {
            segmentedControl.insertSegment(withTitle: item.measurements[index], at: index, animated: true)
        }
        
        segmentedControl.selectedSegmentIndex = item.selectedMeasurment
    }
    
    private func setPhoto() {
        downloadIndicator.isHidden = true
        var isSetPhoto = false
        itemImage.image = nil
        
        let settingImageName = item.imageName
        let imageSize = CGSize(width: itemImage.bounds.width, height: itemImage.bounds.height)
        item.setImage(size: imageSize, type: .detailPhoto) { [settingImageName] image in
            DispatchQueue.main.async {
                guard settingImageName == (self.item.imageName) && !isSetPhoto else { return }
                self.itemImage.image = image
                isSetPhoto = true
                self.itemImage.alpha = 0
                UIView.animate(withDuration: 0.2) {
                    self.itemImage.alpha = 1
                }

                self.downloadIndicator.stopAnimating()
                self.downloadIndicator.isHidden = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            if !isSetPhoto {
                self?.downloadIndicator.isHidden = false
                self?.downloadIndicator.startAnimating()
            }
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
            } else if self?.item.isFavorite == false {
                self?.favoriteButton.setImage(UIImage(named: "heart.png"), for: .normal)
            }
        }
        
        updateCellDelegate?.updateCellAt(indexPath: indexPath)
        updateCellDelegate?.updateFavorites()
    }
    
    @IBAction private func removeButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        DataManager.shared.setNewCountFor(item: item, count: item.count - 1)
        countItemLabel.text = "\(self.item.count)"
        let itemsCount = self.item.count
        
        if itemsCount == 0 {
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
        
        DataManager.shared.setNewCountFor(item: item, count: item.count + 1)
        countItemLabel.text = "\(self.item.count)"
        let itemsCount = self.item.count
        
        if itemsCount == 1 {
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
        priceLabel.text = "\(item.prices[index])Р"
        measurmentLabel.text = item.measurements[index]
        
        DataManager.shared.setNewCountFor(item: item, count: 0)
        item.selectedMeasurment = index
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

extension MenuDetailVC: UpdatingCountPickerPopoverDelegate {
    
    func updateCell(with itemCount: Int) {
        DataManager.shared.setNewCountFor(item: item, count: itemCount)
        countItemLabel.text = "\(itemCount)"
        if itemCount == 0 {
            removeButton.isEnabled = false
            addButton.isEnabled = true
        } else if itemCount > 0 && itemCount < 99 {
            removeButton.isEnabled = true
            addButton.isEnabled = true
        } else if itemCount == 99 {
            removeButton.isEnabled = true
            addButton.isEnabled = false
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
