//
//  ListFooterCell.swift
//  Flan
//
//  Created by Вадим on 27.07.2021.
//

import UIKit

class ListFooterCell: UITableViewCell {
    
    static let reuseId = "ListFooterCell"
    
    @IBOutlet weak var totalSumLabel: UILabel!
    
    @IBOutlet weak var shareView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shareView.layer.cornerRadius = 12
    }
}
