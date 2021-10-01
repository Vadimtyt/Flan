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
    
    weak var superVC: CustomizedCVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headerView.applyShadow()
        
        let tapHeaderView = UITapGestureRecognizer(target: self, action: #selector(CustomizedHeaderView.tapHeaderView))
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(tapHeaderView)
    }
    
    @objc private func tapHeaderView(sender:UITapGestureRecognizer) {
        TapticFeedback.shared.tapticFeedback(.medium)
        guard let tabsCount = superVC?.tabBarController?.tabBar.items?.count else { return }
        superVC?.animatePressingView(headerView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.superVC?.tabBarController?.selectedIndex = tabsCount - 1
        }
    }
}
