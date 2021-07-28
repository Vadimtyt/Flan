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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCellWith(totalSum: Int) {
        totalSumLabel.text = "Итого: ≈\(totalSum)Р"
    }
//
//    @IBAction func infoButtonPressed(_ sender: UIButton) {
//        listDelegate?.footerInfoButtonPressed(button: sender)
//    }
//
//    @IBAction func shareButtonPressed(_ sender: UIButton) {
//        listDelegate?.shareButtonPressed()
//    }
}
