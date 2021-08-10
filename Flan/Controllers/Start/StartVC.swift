//
//  StartVC.swift
//  Flan
//
//  Created by Вадим on 10.08.2021.
//

import UIKit

class StartVC: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        DataManager.shared.configureItems()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let tapBarVC = self?.storyboard?.instantiateViewController(withIdentifier: "TapBar") as? TapBarController else { return }
            self?.present(tapBarVC, animated: true)
        }
    }
}
