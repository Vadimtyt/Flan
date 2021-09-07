//
//  ExtensionViewController.swift
//  Flan
//
//  Created by Вадим on 14.05.2021.
//

import UIKit

extension UIViewController {
    
    // MARK: - Props
    
    private static let indexOfListVC = 2
    
    // MARK: - Funcs
    
    func configureNavigationBarLargeStyle() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        guard #available(iOS 13.0, *) else { return }
        let largeStyle = UINavigationBarAppearance()
        largeStyle.configureWithTransparentBackground()
        
        if #available(iOS 14.0, *) { largeStyle.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 42)] }
        self.navigationController?.navigationBar.scrollEdgeAppearance = largeStyle
    }
    
    func updateListVCBadge(with value: Int) {
        if value != 0 {
            self.navigationController?.tabBarController?.tabBar.items?[UIViewController.indexOfListVC].badgeValue = "\(value)"
        } else if value == 0 {
            self.navigationController?.tabBarController?.tabBar.items?[UIViewController.indexOfListVC].badgeValue = nil
        }
    }
    
    func animatePressingView(_ view: UIView) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            view.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { (_) in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
}
