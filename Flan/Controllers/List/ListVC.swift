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
    var completedList: [MenuItem] = []
    
    private let popUpText = "В этом поле указывается приблизительная сумма, она не учитывает фактический вес всех позиций, цену упаковочных изделий и т.п. Эта сумма отображается исключительно в ознакомительных целях."
    private let popUpTextFontSize: CGFloat = 18
    
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var clearBarButton: UIBarButtonItem!
    @IBOutlet weak var totalSumLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    
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
            newSum += (item.prices[item.selectedMeasurment]) * item.count
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
        
        // Crear buy action
        if !(items.isEmpty) {
            let clearBuyAction = UIAlertAction(title: "Очистить категорию Купить", style: .destructive) { [weak self] _ in
                for item in ListOfMenuItems.shared.list {
                    item.count = 0
                }
                ListOfMenuItems.shared.clearList()
                
                self?.updateList()
                self?.updateListBadge()
            }
            alert.addAction(clearBuyAction)
        }
        
        // Crear buyed action
        if !(completedList.isEmpty) {
            let clearBuyedAction = UIAlertAction(title: "Очистить категорию Куплено", style: .destructive) { [weak self] _ in
                self?.completedList.removeAll()
                
                self?.updateList()
                self?.updateListBadge()
            }
            alert.addAction(clearBuyedAction)
        }
        
        // Crear all action
        if !(items.isEmpty || completedList.isEmpty) {
            let clearAllAction = UIAlertAction(title: "Очистить всё", style: .destructive) { [weak self] _ in
                ListOfMenuItems.shared.clearList()
                self?.completedList.removeAll()
                
                self?.updateList()
                self?.updateListBadge()
            }
            alert.addAction(clearAllAction)
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
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
        
        clearListAlert()
    }
}

extension ListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        changeTotalSumLabel()
        
        if items.isEmpty && completedList.isEmpty {
            clearBarButton.isEnabled = false
        } else { clearBarButton.isEnabled = true }
        
        if items.count == 0 {
            shareButton.isEnabled = false
        } else {
            shareButton.isEnabled = true
        }
        
        var numberOfRows = 0
        if section == 0 {
            numberOfRows = items.count
        } else if section == 1 { numberOfRows = completedList.count}
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle = ""
        if section == 0 {
            sectionTitle = "Купить"
        } else if section == 1 { sectionTitle = "Куплено" }
        return sectionTitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ListCell
        
        var list: [MenuItem] = []
        if indexPath.section == 0 {
            list = items
        } else if indexPath.section == 1 { list = completedList }
        let item = list[indexPath.row]
        var isCompleted = false
        if indexPath.section == 1 { isCompleted = true }
        cell.configureCell(with: item, isCompleted: isCompleted, listDelegate: self)
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            if indexPath.section == 0 {
                ListOfMenuItems.shared.removeFromList(item: self.items[indexPath.row])
            } else if indexPath.section == 1 {
                self.completedList.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .left)
            self.updateListBadge()

            success(true)
        })

        deleteAction.title = "Удалить"
        if #available(iOS 13.0, *) {
            deleteAction.image = UIImage(systemName: "trash")
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        let storyboard = UIStoryboard(name: "MenuDetail", bundle: nil)
            
        guard let menuDetailVC = storyboard.instantiateViewController(withIdentifier: "MenuDetail") as? MenuDetailVC else { return }
        menuDetailVC.item = self.items[indexPath.row]
        menuDetailVC.indexPath = indexPath
        menuDetailVC.updateCellDelegate = self

        self.present(menuDetailVC, animated: true, completion: nil)
    }
}

extension ListVC: UpdatingListCellDelegate {

    func updateList() {
        for index in 0..<items.count {
            if items[index].count == 0 {
                ListOfMenuItems.shared.removeFromList(item: items[index])
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
    
    func addToCompleted(item: MenuItem) {
        let completedItem = MenuItem(item: item)
        
        completedList.insert(completedItem, at: 0)
        listTableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        
        guard let index = items.firstIndex(where: {$0 === item}) else { return }
        ListOfMenuItems.shared.removeFromList(item: item)
        listTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        
        updateListBadge()
    }
    
    func removeFromCompleted(completedItem: MenuItem) {
        guard let completedIndex = completedList.firstIndex(where: {$0 === completedItem}) else { return }
        completedList.remove(at: completedIndex)
        listTableView.deleteRows(at: [IndexPath(row: completedIndex, section: 1)], with: .automatic)
        
        guard let index = ListOfMenuItems.shared.items.firstIndex(where: {$0.name == completedItem.name}) else { return }
        let item = ListOfMenuItems.shared.items[index]
        
        if !(items.contains(where: {$0.name == completedItem.name })) {
            item.count = completedItem.count
            item.selectedMeasurment = completedItem.selectedMeasurment
            ListOfMenuItems.shared.addToList(item: item)
            listTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        } else if items.contains(where: {$0.name == completedItem.name && $0.selectedMeasurment == completedItem.selectedMeasurment}) {
            item.count += completedItem.count
            guard let indexAtList = items.firstIndex(where: {$0.name == completedItem.name}) else { return }
            listTableView.reloadRows(at: [IndexPath(row: indexAtList, section: 0)], with: .automatic)
        }
        updateListBadge()
    }
}

extension ListVC: UpdatingMenuCellDelegate {
    func updateListVCBadge() {
        updateListBadge()
    }
    
    func updateFavorites() {
        //ListOfMenuItems.shared.updateFavorites()
    }
    
    func updateCellAt(indexPath: IndexPath) {
        updateList()
    }
    
    
}

extension ListVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

