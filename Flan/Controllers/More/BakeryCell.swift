//
//  BakeryCell.swift
//  Flan
//
//  Created by Вадим on 07.05.2021.
//

import UIKit

protocol BakeryCellDelegate: class {
    func openMap(with tag: Int)
    func callPhone(with tag: Int)
}

class BakeryCell: UITableViewCell {

    static let reuseId = "BakeryCell"
    weak var bakeryCellDelegate: BakeryCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workTimeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = "Название пекарни"
        addressLabel.text = "Адрес пекарни"
    }

    func configureCell(with bakery: Bakery, and tag: Int) {
        nameLabel.text = bakery.name
        workTimeLabel.text = "\(bakery.openTime):00-\(bakery.closeTime):00"
        addressLabel.text = bakery.address
        
        self.tag = tag
    }
    @IBAction func phoneButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func mapButtonPressed(_ sender: UIButton) {
    }
    
    
}
