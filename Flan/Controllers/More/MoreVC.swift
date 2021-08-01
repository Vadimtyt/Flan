//
//  MoreVC.swift
//  Flan
//
//  Created by Вадим on 07.05.2021.
//

import UIKit
import MessageUI

private let reuseIdentifier = "BakeryCell"
private let bakeries = [
    //Bakery(name: "Флан на Новой", address: "ул.Дорожная, 5 к1", phone: "+7(989)248-14-14", openTime: 8, closeTime: 21),
    Bakery(name: "Флан на Новой", address: "ул.Новая, 14А", phone: "+7(989)248-14-14", workTime: "10:00-20:00 ежедневно"),
    Bakery(name: "Флан на Отдельской", address: "ул.Отдельская 324/7", phone: "+7(988)135-07-07", workTime: "9:00-22:00 ежедневно"),
    Bakery(name: "Флан на Школьной", address: "ул.Школьная, 301А", phone: "+7(918)123-45-67", workTime: "8:00-20:00 пн-пт"),
    Bakery(name: "Флан на Лермонтова", address: "ул.Лермонтова, 216Г", phone: "+7(988)316-21-21", workTime: "8:00-22:00 ежедневно")
]

class MoreVC: UIViewController {
    
    //var bakeries: [Bakery] = []
    let countOfbakeries = 4
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bakeriesTableView: UITableView!
    @IBOutlet weak var feedbackButton: UIButton!
    
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
    
    @IBAction func instagramButtonPressed(_ sender: UIButton) {
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
    
    @IBAction func feedbackButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        animatePressingView(sender)
        sendEmail(subject: NSLocalizedString("Идея для приложения Флан", comment: ""),
                  messageBody: NSLocalizedString("Напишите здесь Вашу идею или предложение по улучшению приложения Флан", comment: ""),
                  to: "vadimtyt@mail.ru")
    }
}

extension MoreVC: UITableViewDelegate, UITableViewDataSource {
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

extension MoreVC: BakeryCellDelegate {
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

extension MoreVC: MFMailComposeViewControllerDelegate {
    func sendEmail(subject: String, messageBody: String, to: String){
        if !MFMailComposeViewController.canSendMail() {
            self.showAlert(title: "Ошибка", message: "Не найден аккаунт вашей почты")
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
