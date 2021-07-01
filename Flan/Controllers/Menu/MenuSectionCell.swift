//
//  MenuSectionCell.swift
//  Flan
//
//  Created by Вадим on 02.07.2021.
//

import UIKit

class MenuSectionCell: UITableViewCell {
    
    static let reuseId = "MenuSectionCell"
    
    @IBOutlet weak var labelBackgroundView: UIView!
    @IBOutlet weak var sectionNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(with header: String) {
        sectionNameLabel.text = header
        sectionNameLabel.backgroundColor = labelBackgroundView.backgroundColor
        self.backgroundView?.alpha = 0.0
    }
}
