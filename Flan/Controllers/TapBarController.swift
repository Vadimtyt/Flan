//
//  TapBarController.swift
//  Flan
//
//  Created by Вадим on 22.04.2021.
//

import UIKit

class TapBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 {

            let indexPath = NSIndexPath(row: 0, section: 0)
            let navigVC = viewController as? UINavigationController
            let finalVC = navigVC?.viewControllers[0] as? MenuVC
            guard let menulVC = finalVC else { return }
            menulVC.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)

        }
    }
    
}
