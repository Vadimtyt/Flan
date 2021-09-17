//
//  ExtensionView.swift
//  Flan
//
//  Created by Вадим on 04.08.2021.
//

import UIKit

extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func applyShadow() {
        clipsToBounds = true
        layer.masksToBounds = false
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.gray.cgColor
    }
}
