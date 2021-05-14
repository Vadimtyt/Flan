//
//  Extension.swift
//  Flan
//
//  Created by Вадим on 14.05.2021.
//

import UIKit

extension UIViewController {
    func updateListBadge(with indexOfListVC: Int) {
        let items = ListOfMenuItems.shared.list
        var sumCountOfItems = 0
        
        for item in items {
            if item.count != 0 {
                sumCountOfItems += item.count
            }
        }
        
        if sumCountOfItems != 0 {
            self.navigationController?.tabBarController?.tabBar.items?[indexOfListVC].badgeValue = "\(sumCountOfItems)"
        } else if sumCountOfItems == 0 {
            self.navigationController?.tabBarController?.tabBar.items?[indexOfListVC].badgeValue = nil
        }
    }
}
