//
//  MenuHeaderCell.swift
//  Flan
//
//  Created by Вадим on 02.07.2021.
//

import UIKit

class MenuHeaderCell: UITableViewCell {
    
    static let reuseId = "MenuHeaderCell"
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var labelBackgroundView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Funcs
    
    func configureCell(with header: String) {
        labelBackgroundView.layer.cornerRadius = 16
        labelBackgroundView.applyShadow()
        
        nameLabel.text = header
        nameLabel.backgroundColor = labelBackgroundView.backgroundColor
        self.backgroundView?.alpha = 0.0
    }
}
