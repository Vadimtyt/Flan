//
//  ExtensionVC.swift
//  Flan
//
//  Created by Вадим on 14.05.2021.
//

import UIKit

extension UIViewController {
    static let indexOfListVC = 2
    
    func configureNavigationBarLargeStyle() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 13.0, *) {
            let largeStyle = UINavigationBarAppearance()
            largeStyle.configureWithTransparentBackground()
            largeStyle.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 42)]
            self.navigationController?.navigationBar.scrollEdgeAppearance = largeStyle
        }
    }
    
    func updateListVCBadge(with value: Int) {
        if value != 0 {
            self.navigationController?.tabBarController?.tabBar.items?[UIViewController.indexOfListVC].badgeValue = "\(value)"
        } else if value == 0 {
            self.navigationController?.tabBarController?.tabBar.items?[UIViewController.indexOfListVC].badgeValue = nil
        }
    }
}