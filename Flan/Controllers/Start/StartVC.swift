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
    @IBOutlet weak var textLabel: UILabel!
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = ""
        textLabel.isHidden = true
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.style = .gray
        }
        activityIndicator.startAnimating()
        
        DataManager.shared.configureDataFromFirebase {
             self.presentApp()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [] in
            if DataManager.shared.getItems().count == 0 {
                self.checkNetworkConnecion()
            }
        }
    }
    
    func presentApp() {
        if !(DataManager.shared.isOnlineMode) && DataManager.shared.getItems().count == 0 {
            textLabel.text = "Ошибка...\nНет предзагруженных данных. Попробуйте перезапустить приложение c подключенным Интернетом"
            textLabel.isHidden = false
        } else {
            guard let tapBarVC = self.storyboard?.instantiateViewController(withIdentifier: "TapBar") as? TapBarController else { return }
            self.present(tapBarVC, animated: true)
        }
    }
    
    // MARK: - Funcs
    private func checkNetworkConnecion() {
        if networkCheck.currentStatus == .satisfied{
            //Do nothing
        } else if networkCheck.currentStatus == .unsatisfied {
            DataManager.shared.configureDataFromSaved()
            showNetworkAlert(title: "Упс...", message: "Кажется пропало соединение с интернетом. Пожалуйста, проверьте cоединение с Интернетом. Информация в приложении может быть неактуальной")
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
    
    private func showNetworkAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OpenSettingsAction action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.presentApp()
        }
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}
