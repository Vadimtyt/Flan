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
    var uncompletedList: [MenuItem] = []
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
        
        uncompletedList = items
        
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
    
    func updateUncompletedList() {
        uncompletedList = items
        for item in items {
            guard let index = completedList.firstIndex(where: {$0 === item}) else { return }
            uncompletedList.remove(at: index)
        }
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        changeTotalSumLabel()
        
        if items.count == 0 {
            clearBarButton.isEnabled = false
            shareButton.isEnabled = false
        } else {
            clearBarButton.isEnabled = true
            shareButton.isEnabled = true
        }
        
        var numberOfRows = 0
        if section == 0 {
            numberOfRows = uncompletedList.count
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
            list = uncompletedList
        } else if indexPath.section == 1 { list = completedList }
        let item = list[indexPath.row]
        var isCompleted = false
        if indexPath.section == 1 { isCompleted = true }
        cell.configureCell(with: item, isCompleted: isCompleted, listDelegate: self, indexPath: indexPath)
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

                ListOfMenuItems.shared.removeFromList(item: self.items[indexPath.row])
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
    
    func addToCompleted(item: MenuItem, indexPath: IndexPath) {
        guard let index = uncompletedList.firstIndex(where: {$0 === item}) else { return }
        uncompletedList.remove(at: index)
        listTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        
        completedList.append(item)
        listTableView.insertRows(at: [IndexPath(row: completedList.count - 1, section: 1)], with: .automatic)
    }
    
    func removeFromCompleted(item: MenuItem, indexPath: IndexPath) {
        guard let completedIndex = completedList.firstIndex(where: {$0 === item}) else { return }
        completedList.remove(at: completedIndex)
        listTableView.deleteRows(at: [IndexPath(row: completedIndex, section: 1)], with: .automatic)
        
        var index = 0
        for item in items {
            if !(completedList.contains(where: {$0 === item})) && uncompletedList.firstIndex(where: {$0 === item}) == nil {
                uncompletedList.insert(item, at: index)
                listTableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            } else if uncompletedList.contains(where: {$0 === item}) { index += 1; print("add index")}
        }
    }
}

extension ListVC: UpdatingMenuCellDelegate {
    func updateListVCBadge() {
        updateListBadge()
    }
    
    func updateFavorites() {
        //
    }
    
    func updateCellAt(indexPath: IndexPath) {
        
        listTableView.reloadData()
    }
    
    
}

extension ListVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

