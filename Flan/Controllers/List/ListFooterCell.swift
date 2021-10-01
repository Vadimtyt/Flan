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
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var totalSumLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.applyShadow()
        
        if #available(iOS 13.0, *) {
            shareButton.layer.borderColor =  UIColor.opaqueSeparator.cgColor
        } else {
            shareButton.layer.borderColor =  UIColor.lightGray.cgColor
        }
        shareButton.layer.borderWidth = 2
        shareButton.layer.cornerRadius = 12
        shareButton.applyShadow()
    }
}
