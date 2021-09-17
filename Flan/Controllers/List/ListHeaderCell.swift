//
//  ListHeaderCell.swift
//  Flan
//
//  Created by Вадим on 27.07.2021.
//

import UIKit

class ListHeaderCell: UITableViewCell {
    
    // MARK: - Props
    
    static let reuseId = "ListHeaderCell"
    
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
        
        labelBackgroundView.clipsToBounds = true
        labelBackgroundView.layer.masksToBounds = false
        labelBackgroundView.layer.shadowRadius = 3
        labelBackgroundView.layer.shadowOpacity = 0.5
        labelBackgroundView.layer.shadowOffset = CGSize(width: 1, height: 1)
        labelBackgroundView.layer.shadowColor = UIColor.gray.cgColor
        
        nameLabel.text = header
        nameLabel.backgroundColor = labelBackgroundView.backgroundColor
        self.backgroundView?.alpha = 0.0
    }
}
