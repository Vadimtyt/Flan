//
//  ListVC.swift
//  Flan
//
//  Created by Вадим on 07.04.2021.
//

import UIKit

private let reuseIdentifier = "ListCell"

class ListVC: UIViewController {
    var items: [MenuItem] { get { return ListOfMenuItems.shared.list } }
    
    private let popUpText = "В этом поле указывается приблизительная сумма, она не учитывает фактический вес всех позиций, цену упаковочных изделий и т.п. Эта сумма отображается исключительно в ознакомительных целях."
    private let popUpTextFontSize: CGFloat = 18
    
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var totalSumLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var clearBarButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.delegate = self
        listTableView.dataSource = self
        
        listTableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        changeTotalSumLabel()
        listTableView.showsVerticalScrollIndicator = false
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
    
    func clearListAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Save action
        let clearAction = UIAlertAction(title: "Очистить cписок", style: .destructive) { [weak self] _ in
            for item in ListOfMenuItems.shared.list {
                item.count = 0
            }
            ListOfMenuItems.shared.list.removeAll()
            self?.updateList()
            self?.updateListBadge()
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)

        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let textTopConstraint: CGFloat = 6
        let popUpWidth = 294
        let popUpHeight = 163
        
        let vc = InfoPopover(text: popUpText, fontSize: popUpTextFontSize, topConstraint: textTopConstraint)
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.sourceView = sender
        popover.delegate = self
        
        popover.sourceRect = CGRect(x: self.infoButton.bounds.minX - 19,
                                       y: self.infoButton.bounds.minY,
                                       width: 0,
                                       height: 0)
        popover.permittedArrowDirections = .down
        vc.preferredContentSize = CGSize(width: popUpWidth, height: popUpHeight)
        
        present(vc, animated: true, completion:nil)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let message = getTextList()
        let objectsToShare = [message]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func clearListButtonPressed(_ sender: UIBarButtonItem) {
        TapticFeedback.shared.tapticFeedback(.medium)
        
        if items.count != 0 {
            clearListAlert()
        }
    }
}

extension ListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        changeTotalSumLabel()
        
        if items.count == 0 {
            clearBarButton.image = nil
            clearBarButton.title = ""
        } else {
            if #available(iOS 13.0, *) {
                clearBarButton.image = UIImage(systemName: "trash")
            } else { clearBarButton.title = "Очистить"}
        }
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ListCell
 
        let item = items[indexPath.row]
        cell.configureCell(with: item)
        cell.listDelegate = self
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

                ListOfMenuItems.shared.removeFromList(item: self.items[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .left)
                self.updateListBadge()

                success(true)
            })

        if #available(iOS 13.0, *) {
            deleteAction.image = UIImage(systemName: "trash")
        } else {
            deleteAction.title = "Удалить"
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension ListVC: UpdatingListCellDelegate {
    func updateList() {
        for index in 0..<items.count {
            if items[index].count == 0 {
                ListOfMenuItems.shared.list.remove(at: index)
                listTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .middle)
                return
             }
        }
        self.listTableView.reloadData()
    }
    
    func updateListBadge() {
        let badgeValue = ListOfMenuItems.shared.getValueForListBadge()
        updateListVCBadge(with: badgeValue)
    }
}


extension ListVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

