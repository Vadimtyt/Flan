//
//  TapBarController.swift
//  Flan
//
//  Created by Вадим on 22.04.2021.
//

import UIKit

class TapBarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - Props
    
    var previousController: UIViewController?
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    // MARK: - Funcs
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if previousController == nil {
            previousController = viewController
        }
        
        let tabBarIndex = tabBarController.selectedIndex
        
        if tabBarIndex == 0 && previousController == viewController {
            let navigVC = viewController as? UINavigationController
            let finalVC = navigVC?.viewControllers[0] as? MenuVC
            guard let menulVC = finalVC else { return }
            
            let currentPosition = menulVC.tableView.contentOffset.y
            guard let height = menulVC.navigationController?.navigationBar.frame.height else { return }

            guard currentPosition > -height else { return }
            menulVC.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            //menulVC.tableView.scrollRectToVisible(CGRect(x: 0, y: -height - 10, width: 1, height: 1), animated: true)
        }
        
        if tabBarIndex == 3 && previousController == viewController {
            
            let navigVC = viewController as? UINavigationController
            let finalVC = navigVC?.viewControllers[0] as? CustomizedCVC
            guard let customizedVC = finalVC else { return }
            
            let currentPosition = customizedVC.collectionView.contentOffset.y
            guard let height = customizedVC.navigationController?.navigationBar.frame.height else { return }
            
            guard currentPosition > height else { return }
            customizedVC.collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        }
        
        previousController = viewController
    }
}
