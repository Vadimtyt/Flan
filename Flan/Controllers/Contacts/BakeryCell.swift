//
//  BakeryCell.swift
//  Flan
//
//  Created by Вадим on 07.05.2021.
//

import UIKit

// MARK: - Protocol

protocol BakeryCellDelegate: AnyObject {
    func callPhone(with tag: Int)
    func openMap(with tag: Int)
}

class BakeryCell: UITableViewCell {
    
    // MARK: - Props
    
    private var bakery: Bakery = Bakery()
    
    static let reuseId = "BakeryCell"
    weak var bakeryCellDelegate: BakeryCellDelegate?
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var workTimeLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    
    @IBOutlet private weak var phoneButton: UIButton!
    @IBOutlet private weak var mapButton: UIButton!
    
    @IBOutlet private weak var mainView: UIView!
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = "Название пекарни"
        addressLabel.text = "Адрес пекарни"
        
        mapButton.backgroundColor = Colors.mapIconBackground
    }
    
    override func layoutSubviews() {
        phoneButton.layer.cornerRadius = 8
        phoneButton.applyShadow()
        phoneButton.layer.shadowOpacity = 1
        mapButton.layer.cornerRadius = 8
        mapButton.applyShadow()
        mapButton.layer.shadowOpacity = 1
        mainView.layer.cornerRadius = 16
        mainView.applyShadow()
        mainView.layer.shadowOpacity = 0.5
        mainView.layer.shadowRadius = 6
    }
    
    // MARK: - Funcs

    func configureCell(with bakery: Bakery, and tag: Int) {
        selectionStyle = .none
        self.bakery = bakery
        
        nameLabel.text = bakery.name
        workTimeLabel.text = bakery.workTime
        addressLabel.text = bakery.address
        
        nameLabel.adjustsFontSizeToFitWidth = true
        
        self.tag = tag
    }
    
    // MARK: - @IBActions
    
    @IBAction private func phoneButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.medium)
        animatePressingView(sender)
        bakeryCellDelegate?.callPhone(with: tag)
    }
    
    @IBAction private func mapButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        animatePressingView(sender)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let tag = self?.tag else { return }
            self?.bakeryCellDelegate?.openMap(with: tag)
        }
    }
}
