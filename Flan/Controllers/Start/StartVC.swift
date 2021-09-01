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
    private let textForOfflineMode = "Оффлайн режим"
    private let textForRepeatConnection = "Повторить загрузку"
    
    // MARK: - @IBOutlet
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    // MARK: - Initialization
    
    override func viewWillAppear(_ animated: Bool) {
        configureElements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkNetworkConnecion()
    }
    
    // MARK: - Funcs
    
    private func configureElements() {
        textLabel.text = ""
        textLabel.isHidden = true
        actionButton.isHidden = true
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.style = .gray
        }
    }
    
    // MARK: - Funcs
    private func checkNetworkConnecion() {
        if networkCheck.currentStatus == .satisfied{
            DataManager.shared.configureDataFromFirebase {
                 self.presentApp()
            }
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.prepareOfflineMode()
            }
        } else if networkCheck.currentStatus == .unsatisfied {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            showNetworkAlert(title: "Упс...", message: "Пожалуйста, проверьте cоединение с Интернетом")
        }
    }
    
    private func prepareOfflineMode() {
        guard DataManager.shared.offlineModeIsRedi() else {
            offlineModeDisabled()
            return
        }
        textLabel.text = "Вы можете включить оффлайн режим, при этом отобразятся последние загруженные данные, но они могут быть неактуальны"
        textLabel.isHidden = false
        actionButton.setTitle(textForOfflineMode, for: .normal)
        actionButton.isHidden = false
    }
    
    private func offlineModeDisabled() {
        actionButton.setTitle(textForRepeatConnection, for: .normal)
        actionButton.isHidden = false
    }
    
    private func showNetworkAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OpenSettingsAction action
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.prepareOfflineMode()
        }
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    private func setDataFromSaved() {
        DataManager.shared.configureDataFromSaved()
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func presentApp() {
        guard let tapBarVC = self.storyboard?.instantiateViewController(withIdentifier: "TapBar") as? TapBarController else { return }
        self.present(tapBarVC, animated: true)
    }
    
    // MARK: - @IBActions
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        if actionButton.currentTitle == textForOfflineMode {
            setDataFromSaved()
            presentApp()
        } else if actionButton.currentTitle == textForRepeatConnection {
            checkNetworkConnecion()
        }
    }
}
