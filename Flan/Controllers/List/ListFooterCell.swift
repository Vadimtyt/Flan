//
//  ListFooterCell.swift
//  Flan
//
//  Created by Вадим on 27.07.2021.
//

import UIKit

protocol UpdatingListFooterDelegate: AnyObject {
    func footerInfoButtonPressed(button: UIButton)
    func shareButtonPressed()
}

class ListFooterCell: UITableViewCell {
    
    static let reuseId = "ListFooterCell"
    
    weak var listDelegate: UpdatingListFooterDelegate?
    
    @IBOutlet weak var totalSumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCellWith(totalSum: Int, listDelegate: UpdatingListFooterDelegate) {
        totalSumLabel.text = "Итого: ≈\(totalSum)Р"
        self.listDelegate = listDelegate
    }
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        listDelegate?.footerInfoButtonPressed(button: sender)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        listDelegate?.shareButtonPressed()
    }
}
