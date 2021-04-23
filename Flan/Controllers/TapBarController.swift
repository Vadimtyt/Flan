//
//  TapBarController.swift
//  Flan
//
//  Created by Вадим on 22.04.2021.
//

import UIKit

class TapBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let indexOfListPage = 2
    
    override func viewDidLoad() {
        
    }
    
    func updateListBadge() {
        self.tabBar.items?[indexOfListPage].badgeValue = "117"
    }
}

protocol UITabBarControllerDelegate: class {}
