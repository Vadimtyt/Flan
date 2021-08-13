//
//  StartVC.swift
//  Flan
//
//  Created by Вадим on 10.08.2021.
//

import UIKit
import Network

class StartVC: UIViewController {
    
    // MARK: - Props
    private var networkCheck = NetworkCheck.sharedInstance()
    
    // MARK: - @IBOutlet
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.style = .gray
        }
        activityIndicator.startAnimating()
        
        DataManager.shared.configureData {
            guard let tapBarVC = self.storyboard?.instantiateViewController(withIdentifier: "TapBar") as? TapBarController else { return }
            self.present(tapBarVC, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.checkNetworkConnecion()
        }
    }
    
    // MARK: - Funcs
    private func checkNetworkConnecion() {
        if networkCheck.currentStatus == .satisfied{
            //Do nothing
        } else if networkCheck.currentStatus == .unsatisfied {
            showNetworkAlert(title: "Упс...", message: "Кажется пропало соединение с интернетом. Пожалуйста, проверьте cоединение с Интернетом")
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
    
    private func showNetworkAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OpenSettingsAction action
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}
