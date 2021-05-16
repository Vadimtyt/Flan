//
//  Extension.swift
//  Flan
//
//  Created by Вадим on 14.05.2021.
//

import UIKit

extension UIViewController {
    static let indexOfListVC = 2
    
    func updateListVCBadge(with value: Int) {
        if value != 0 {
            self.navigationController?.tabBarController?.tabBar.items?[UIViewController.indexOfListVC].badgeValue = "\(value)"
        } else if value == 0 {
            self.navigationController?.tabBarController?.tabBar.items?[UIViewController.indexOfListVC].badgeValue = nil
        }
    }
}
