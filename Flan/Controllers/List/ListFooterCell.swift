//
//  ListFooterCell.swift
//  Flan
//
//  Created by Вадим on 27.07.2021.
//

import UIKit

class ListFooterCell: UITableViewCell {
    
    // MARK: - Props
    
    static let reuseId = "ListFooterCell"
    
    // MARK: - @IBOutlets
    
    @IBOutlet weak var totalSumLabel: UILabel!
    
    @IBOutlet weak var shareView: UIView!
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shareView.layer.borderColor =  UIColor.lightGray.cgColor
        shareView.layer.borderWidth = 2.5
        shareView.layer.cornerRadius = 12
    }
}
