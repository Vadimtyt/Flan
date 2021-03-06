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
    
    private var bakeries: [Bakery] { DataManager.shared.getBakeries() }
    private let countOfbakeries = 4
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var headerContainerView: UIView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var bakeriesTableView: UITableView!
    @IBOutlet private weak var feedbackButton: UIButton!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillLayoutSubviews() {
        headerLabel.layer.cornerRadius = 14
        headerLabel.layer.masksToBounds = true
        headerContainerView.layer.cornerRadius = headerLabel.layer.cornerRadius
        headerContainerView.applyShadow()
        headerContainerView.layer.shadowRadius = 6
        bakeriesTableView.layer.cornerRadius = 16
        feedbackButton.layer.cornerRadius = 16
        feedbackButton.applyShadow()
        feedbackButton.layer.shadowRadius = 6
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateBackgound()
    }
    
    // MARK: - Funcs
    
    private func configureTableView() {
        bakeriesTableView.delegate = self
        bakeriesTableView.dataSource = self
        bakeriesTableView.isScrollEnabled = false
        
        bakeriesTableView.register(UINib(nibName: "BakeryCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }
    
    private func updateBackgound() {
        if bakeries.isEmpty {
            bakeriesTableView.setEmptyView(title: Labels.ContactsVC.emptyViewTitle,
                                           message: Labels.ContactsVC.emptyViewMessage,
                                           messageImage: UIImage(named: "cloudError.png")!)
        } else {
            bakeriesTableView.restore()
        }
    }
    
    // MARK: - @IBActions
    
    @IBAction private func instagramButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.medium)
        animatePressingView(sender)
        let appURL = URL(string: "instagram://user?username=\(Labels.ContactsVC.instagramUsername)")!
        let application = UIApplication.shared

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [] in
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                // if Instagram app is not installed, open URL inside Safari
                let webURL = URL(string: "https://instagram.com/\(Labels.ContactsVC.instagramUsername)")!
                application.open(webURL)
            }
        }
    }
    
    @IBAction private func feedbackButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        animatePressingView(sender)
        let email = Labels.ContactsVC.flanEmail
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.sendEmail(subject: NSLocalizedString(Labels.ContactsVC.sendEmailSubject, comment: ""),
                            messageBody: NSLocalizedString(Labels.ContactsVC.sendEmailMessageBody, comment: ""),
                            to: email)
        }
    }
}

// MARK: - Table view data source

extension ContactsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bakeries.count
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
            self.showAlert(title: Labels.ContactsVC.showAlertTitle, message: Labels.ContactsVC.showAlertMessage)
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
