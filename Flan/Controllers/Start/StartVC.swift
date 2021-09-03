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
    @IBOutlet weak var reconnectButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var offlineModeButton: UIButton!
    
    // MARK: - Initialization
    
    override func viewWillAppear(_ animated: Bool) {
        configureElements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tryToConnect()
    }
    
    // MARK: - Funcs
    
    private func configureElements() {
        textLabel.text = ""
        reconnectButton.isHidden = true
        reconnectButton.layer.cornerRadius = 16
        textLabel.isHidden = true
        offlineModeButton.isHidden = true
        offlineModeButton.layer.cornerRadius = 14
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.style = .gray
        }
    }
    
    // MARK: - Funcs
    private func tryToConnect() {
        if networkCheck.currentStatus == .satisfied{
            DataManager.shared.configureDataFromFirebase {
                 self.presentApp()
            }
            reconnectButton.isHidden = true
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
        reconnectButton.isHidden = false
        guard DataManager.shared.offlineModeIsRedi() else { return }
        textLabel.text = "Вы можете включить оффлайн режим, при этом отобразятся последние загруженные данные, но они могут быть неактуальны"
        textLabel.isHidden = false
        offlineModeButton.setTitle(textForOfflineMode, for: .normal)
        offlineModeButton.isHidden = false
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
        reconnectButton.isHidden = false
    }
    
    private func presentApp() {
        guard let tapBarVC = self.storyboard?.instantiateViewController(withIdentifier: "TapBar") as? TapBarController else { return }
        self.present(tapBarVC, animated: true)
    }
    
    // MARK: - @IBActions
    
    @IBAction func reconnectButtonPressed(_ sender: UIButton) {
        animatePressingView(sender)
        tryToConnect()
    }
    
    @IBAction func offlineModeButtonPressed(_ sender: UIButton) {
        animatePressingView(sender)
        setDataFromSaved()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.presentApp()
        }
    }
}
