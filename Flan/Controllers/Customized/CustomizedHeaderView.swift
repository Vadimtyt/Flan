//
//  CustomizedHeaderView.swift
//  Flan
//
//  Created by Вадим on 23.05.2021.
//

import UIKit

class CustomizedHeaderView: UICollectionReusableView {
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var headerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapHeaderView = UITapGestureRecognizer(target: self, action: #selector(CustomizedHeaderView.tapHeaderView))
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(tapHeaderView)
    }
    
    @objc private func tapHeaderView(sender:UITapGestureRecognizer) {
        let tabBarController: UITabBarController = (self.window?.rootViewController as? UITabBarController)!
        tabBarController.selectedIndex = 1
    }
}
