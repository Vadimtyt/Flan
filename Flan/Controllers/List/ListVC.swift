//
//  ListVC.swift
//  Flan
//
//  Created by Вадим on 07.04.2021.
//

import UIKit

private let reuseIdentifier = "ListCell"

class ListVC: UIViewController {

    private let indexOfListVC = 2
    
    var items: [MenuItem] = ListOfMenuItems.shared.list
    
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var totalSumLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.delegate = self
        listTableView.dataSource = self
        setupGestures()
        
        listTableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        changeTotalSumLabel()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateList()
    }
    
    func changeTotalSumLabel() {
        var newSum = 0
        for item in items {
            newSum += item.price * item.count
        }
        
        if newSum == 0 {
            totalSumLabel.text = "Итого: 0Р"
        } else { totalSumLabel.text = "Итого: ≈\(newSum)Р" }
    }
    
    func getTextList() -> String {
        var list = "Весь список:"
        for item in items {
            list += "\n\(item.name) - \(item.count) шт.,"
        }
        list.removeLast()
        list += "\n\(totalSumLabel.text ?? "")"
        return list
    }
    
    private func setupGestures() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGesture.numberOfTapsRequired = 1
        infoButton.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func tapped() {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") else { return }
        popVC.modalPresentationStyle = .popover
        
        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate=self
        popOverVC?.sourceView = self.infoButton
        popOverVC?.sourceRect = CGRect(x: self.infoButton.bounds.minX - 19,
                                       y: self.infoButton.bounds.minY,
                                       width: 0,
                                       height: 0)
        popOverVC?.permittedArrowDirections = .down
        popVC.preferredContentSize = CGSize(width: 267, height: 117)
        
        self.present(popVC, animated: true)
    }
    
    func clearAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        // Save action
        let clearAction = UIAlertAction(title: "Очистить", style: .default) { [weak self] _ in
            for item in ListOfMenuItems.shared.list {
                item.count = 0
            }
            ListOfMenuItems.shared.list.removeAll()
            self?.updateList()
            self?.updateListBadge()
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Отмена", style: .destructive)
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let message = getTextList()
        let objectsToShare = [message]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        self.present(activityVC, animated: true, completion: nil)
                
    }
    
    @IBAction func clearListButtonPressed(_ sender: UIBarButtonItem) {
        if items.count != 0 {
            clearAlert(title: "Очистить список?", message: "")
        }
    }
    
}

extension ListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        changeTotalSumLabel()
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ListCell
 
        let item = items[indexPath.row]
        cell.configureCell(with: item)
        cell.listDelegate = self
 
        return cell
    }
    
    
}

extension ListVC: updatingListCell {
    func updateList() {
        items = ListOfMenuItems.shared.list
        for index in 0..<items.count {
            if items[index].count == 0 {
                ListOfMenuItems.shared.list.remove(at: index)
                items = ListOfMenuItems.shared.list
                listTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .middle)
                return
             }
        }
        
        self.listTableView.reloadData()
    }
    
    func updateListBadge() {
        let items = ListOfMenuItems.shared.list
        var sumCountOfItems = 0
        
        for item in items {
            if item.count != 0 {
                sumCountOfItems += item.count
            }
        }
        
        if sumCountOfItems != 0 {
            self.navigationController?.tabBarController?.tabBar.items?[indexOfListVC].badgeValue = "\(sumCountOfItems)"
        } else if sumCountOfItems == 0 {
            self.navigationController?.tabBarController?.tabBar.items?[indexOfListVC].badgeValue = nil
        }
    }
}


extension ListVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
