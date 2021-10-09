//
//  ListCell.swift
//  Flan
//
//  Created by Вадим on 07.04.2021.
//

import UIKit

// MARK: - Protocol

protocol UpdatingListCellDelegate: AnyObject {
    func removeRow(at indexPath: IndexPath)
    func updateListVCBadgeAndTotalSum()
    func addToCompleted(item: MenuItem)
    func removeFromCompleted(completedItem: MenuItem)
}

class ListCell: UITableViewCell {
    
    static let reuseId = "ListCell"
    
    // MARK: - Props
    private var item: MenuItem = MenuItem()
    private weak var listDelegate: UpdatingListCellDelegate?
    
    private var checkmark = false {
        didSet {
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
        }
    }
    
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    
    @IBOutlet private weak var removeButton: UIButton!
    @IBOutlet private weak var countItemLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    
    @IBOutlet private weak var checkmarkButton: UIButton!
    
    @IBOutlet private weak var mainView: UIView!
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        setupViews()
        setupElements()
    }
    
    override func prepareForReuse() {
        resetAll()
    }
    
    // MARK: - Funcs
    
    func configureCell(with item: MenuItem, isCompleted: Bool, listDelegate: UpdatingListCellDelegate) {
        self.item = item
        self.listDelegate = listDelegate
        self.checkmark = isCompleted
    }
    
    private func setupViews() {
        selectionStyle = .none

        mainView.layer.cornerRadius = 16
        checkmarkButton.layer.cornerRadius = 12
        checkmarkButton.applyShadow()
        checkmarkButton.layer.shadowOpacity = 0.4
        countItemLabel.layer.borderColor =  UIColor.yellow.cgColor
        countItemLabel.layer.borderWidth = 2.5
        countItemLabel.layer.cornerRadius = 16
        countItemLabel.roundCorners(.allCorners, radius: 16)
        
        removeButton.layer.cornerRadius = 16
        addButton.layer.cornerRadius = 16
    }
    
    private func setupElements() {
        if item.count >= 99 {
            addButton.isEnabled = false
        }
        
        nameLabel.text = item.name
        nameLabel.adjustsFontSizeToFitWidth = true
        priceLabel.text = "\(item.prices[item.selectedMeasurment])₽/\(item.measurements[item.selectedMeasurment])"
        countItemLabel.text = "\(item.count)"
    }
    
    private func resetAll() {
        checkmarkButton.imageView?.image = nil
        
        nameLabel.text = nil
        priceLabel.text = nil
        countItemLabel.text = nil
    }
    
    // MARK: - @IBActions
    
    @IBAction private func removeButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let itemIndex = DataManager.shared.getList().firstIndex(where: { $0 === item })
        DataManager.shared.setNewCountFor(item: item, count: item.count - 1)
        let itemCount = item.count
        countItemLabel.text = "\(self.item.count)"
        
        if self.item.count < 99  {
            addButton.isEnabled = true
        } else { addButton.isEnabled = false }
        
        removeButton.backgroundColor = .yellow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [itemIndex, itemCount, weak self] in
            self?.removeButton.backgroundColor = nil
            
            guard itemCount == 0, let row = itemIndex else { return }
            let indexPath = IndexPath(row: row, section: 0)
            self?.listDelegate?.removeRow(at: indexPath)
        }
        
        listDelegate?.updateListVCBadgeAndTotalSum()
    }
    
    @IBAction private func addButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        DataManager.shared.setNewCountFor(item: item, count: item.count + 1)
        countItemLabel.text = "\(self.item.count)"
        
        if self.item.count >= 99 {
            addButton.isEnabled = false
        }
        
        addButton.backgroundColor = .yellow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.addButton.backgroundColor = nil
        }
        
        listDelegate?.updateListVCBadgeAndTotalSum()
    }
    
    @IBAction private func checkmarkButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        animatePressingView(sender)
        checkmark = !checkmark
        if checkmark {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let item = self?.item else { return }
                self?.listDelegate?.addToCompleted(item: item)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let item = self?.item else { return }
                self?.listDelegate?.removeFromCompleted(completedItem: item)
            }
        }
    }
}
