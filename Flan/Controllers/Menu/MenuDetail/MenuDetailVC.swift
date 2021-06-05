//
//  MenuDetailVC.swift
//  Flan
//
//  Created by Вадим on 01.06.2021.
//

import UIKit

class MenuDetailVC: UIViewController {
    
    var item: MenuItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(item.name)
    }
}
