//
//  MenuHeaderCell.swift
//  Flan
//
//  Created by Вадим on 02.07.2021.
//

import UIKit

class MenuHeaderCell: UITableViewCell {
    
    static let reuseId = "MenuHeaderCell"
    
    @IBOutlet weak var labelBackgroundView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(with header: String) {
        labelBackgroundView.layer.cornerRadius = 16
        nameLabel.text = header
        nameLabel.backgroundColor = labelBackgroundView.backgroundColor
        self.backgroundView?.alpha = 0.0
    }
}
