//
//  ContactsVC.swift
//  Flan
//
//  Created by Вадим on 07.05.2021.
//

import UIKit
import MessageUI

private let reuseIdentifier = "BakeryCell"

class ContactsVC: UIViewController {
    
    // MARK: - Props
    
    private var bakeries: [Bakery] { get { return DataManager.shared.getBakeries() } }
    private let countOfbakeries = 4
    private let email = "PekarnyaFlanApp@gmail.com"
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var bakeriesTableView: UITableView!
    @IBOutlet private weak var feedbackButton: UIButton!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        
        bakeriesTableView.delegate = self
        bakeriesTableView.dataSource = self
        bakeriesTableView.isScrollEnabled = false
        
        bakeriesTableView.register(UINib(nibName: "BakeryCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillLayoutSubviews() {
        headerLabel.roundCorners(.allCorners, radius: 14)
        bakeriesTableView.layer.cornerRadius = 16
        feedbackButton.layer.cornerRadius = 16
        
        bakeriesTableView.separatorColor = .black
        bakeriesTableView.separatorStyle = .singleLine
        bakeriesTableView.separatorInset = .zero
    }
    
    // MARK: - @IBActions
    
    @IBAction private func instagramButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.medium)
        animatePressingView(sender)
        let Username = "pekarnya_flan" // Instagram Username here
        let appURL = URL(string: "instagram://user?username=\(Username)")!
        let application = UIApplication.shared

        if application.canOpenURL(appURL) {
            application.open(appURL)
        } else {
            // if Instagram app is not installed, open URL inside Safari
            let webURL = URL(string: "https://instagram.com/\(Username)")!
            application.open(webURL)
        }
    }
    
    @IBAction private func feedbackButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        animatePressingView(sender)
        sendEmail(subject: NSLocalizedString("Идея для приложения Флан", comment: ""),
                  messageBody: NSLocalizedString("Напишите здесь Вашу идею или предложение по улучшению приложения Флан", comment: ""),
                  to: email)
    }
}

// MARK: - Table view data source

extension ContactsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countOfbakeries
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BakeryCell
 
        let bakery = bakeries[indexPath.row]
        cell.configureCell(with: bakery, and: indexPath.row)
        cell.bakeryCellDelegate = self
 
        return cell
    }
}

// MARK: - BaceryCell delegate

extension ContactsVC: BakeryCellDelegate {
    func callPhone(with tag: Int) {
        let phoneNumber = bakeries[tag].phone
        if let phoneCallURL = URL(string: "tel://" + phoneNumber) {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    func openMap(with tag: Int) {
        let storyboard = UIStoryboard(name: "Map", bundle: nil)
        
        guard let mapVC = storyboard.instantiateViewController(withIdentifier: "mapVC") as? MapVC else { return }
        mapVC.bakery = bakeries[tag]
        self.present(mapVC, animated: true)
    }
}

// MARK: - MFMail compose view controller delegate

extension ContactsVC: MFMailComposeViewControllerDelegate {
    func sendEmail(subject: String, messageBody: String, to: String){
        if !MFMailComposeViewController.canSendMail() {
            self.showAlert(title: "Ошибка", message: "Не найден аккаунт вашей почты, но вы можете другим способом направить свое письмо на email: \(email)")
            return
        }
        
        let picker = MFMailComposeViewController()
        
        picker.setSubject(subject)
        picker.setMessageBody(messageBody, isHTML: true)
        picker.setToRecipients([to])
        picker.mailComposeDelegate = self
        
        self.present(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OpenSettingsAction action
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}
