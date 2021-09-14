//
//  ListVC.swift
//  Flan
//
//  Created by Вадим on 07.04.2021.
//

import UIKit

private let reuseCellID = "ListCell"
private let reuseHeaderID = "ListHeaderCell"
private let reuseFooterID = "ListFooterCell"

class ListVC: UIViewController {
    
    // MARK: - Props
    
    private var items: [MenuItem] { DataManager.shared.getList() }
    private var completedItems: [MenuItem] { get { return DataManager.shared.getCompletedList() } }

    private let popUpTextFontSize: CGFloat = 18
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var listTableView: UITableView!
    @IBOutlet private weak var clearBarButton: UIBarButtonItem!
    
    private weak var totalSumLabel: UILabel?
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        updateTotalSumLabel()
        updateBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateList()
    }
    
    // MARK: - Funcs
    
    private func setupTableView() {
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.separatorStyle = .none
        listTableView.register(UINib(nibName: reuseCellID, bundle: nil), forCellReuseIdentifier: ListCell.reuseId)
        listTableView.register(UINib(nibName: reuseHeaderID, bundle: nil), forCellReuseIdentifier: ListHeaderCell.reuseId)
        listTableView.register(UINib(nibName: reuseFooterID, bundle: nil), forCellReuseIdentifier: ListFooterCell.reuseId)
    }
    
    private func getTotalSum() -> Int {
        var newSum = 0
        for item in items {
            newSum += (item.prices[item.selectedMeasurment]) * item.count
        }
        
        return newSum
    }
    
    private func updateTotalSumLabel() {
        let totalSum = getTotalSum()
        if totalSum > 99999 {
            totalSumLabel?.text = "Итого: 99999+₽"
        } else { totalSumLabel?.text = "Итого: ≈\(totalSum)₽" }
    }
    
    private func updateBackground() {
        if items.isEmpty && completedItems.isEmpty {
            listTableView.setEmptyView(title: Labels.ListVC.emptyViewTitle,
                                       message: Labels.ListVC.emptyViewMessage,
                                       messageImage: UIImage(named: "emptyList.png")!)
        } else { listTableView.restore() }
    }
    
    private func getTextList() -> String {
        var list = "Список покупок во Флане:\n"
        for item in items {
            
            let name = item.name,
                count = item.count,
                measurment = item.measurements[item.selectedMeasurment],
                price = item.prices[item.selectedMeasurment]
            
            list += "-\(name)\n      \(count) * \(measurment)/\(price)Р,\n"
        }
        list.removeLast()
        list.removeLast()
        let totalSum = "Примерная сумма: " + String(getTotalSum()) + "₽"
        list += "\n" + totalSum
        return list
    }
    
    // MARK: - @IBActions
    
    @IBAction private func infoButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)

        let popUpWidth: CGFloat = 288
        let popUpHeight: CGFloat = 163

        var arrowY: CGFloat = 0
        let rectOfCell = listTableView.rectForRow(at: IndexPath(row: items.count - 1, section: 0))
        let rectOfCellInSuperview = listTableView.convert(rectOfCell, to: listTableView.superview)
        if rectOfCellInSuperview.maxY < popUpHeight {
            arrowY = sender.bounds.maxY
        } else {
            arrowY = sender.bounds.minY
        }

        let vc = InfoPopover(text: Labels.ListVC.popoverText, fontSize: popUpTextFontSize)
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!

        if rectOfCellInSuperview.maxY < popUpHeight {
            popover.permittedArrowDirections = .up
        } else { popover.permittedArrowDirections = .down }

        popover.sourceView = sender
        popover.delegate = self
        popover.sourceRect = CGRect(x: sender.bounds.minX - 19,
                                       y: arrowY,
                                       width: 0,
                                       height: 0)

        vc.preferredContentSize = CGSize(width: popUpWidth, height: popUpHeight)

        present(vc, animated: true, completion:nil)
    }

    @IBAction private func shareButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        animatePressingView(sender)
        
        let message = getTextList()
        let objectsToShare = [message]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        activityVC.popoverPresentationController?.sourceView = sender

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction private func clearListButtonPressed(_ sender: UIBarButtonItem) {
        TapticFeedback.shared.tapticFeedback(.medium)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Crear buy action
        if !(items.isEmpty) {
            let clearBuyAction = UIAlertAction(title: "Очистить список Купить", style: .destructive) { [weak self] _ in
                for item in DataManager.shared.getList() {
                    item.count = 0
                }
                DataManager.shared.clearList()
                self?.listTableView.deleteSections([0], with: .fade)
                
                self?.updateListBadge()
            }
            alert.addAction(clearBuyAction)
        }
        
        // Crear buyed action
        if !(completedItems.isEmpty) {
            let clearBuyedAction = UIAlertAction(title: "Очистить список Куплено", style: .destructive) { [weak self] _ in
                DataManager.shared.clearCompletedList()
                guard let sectionsCount = self?.listTableView.numberOfSections else { return }
                self?.listTableView.deleteSections([sectionsCount - 1], with: .fade)
                
                self?.updateListBadge()
            }
            alert.addAction(clearBuyedAction)
        }
        
        // Crear all action
        if !(items.isEmpty || completedItems.isEmpty) {
            let clearAllAction = UIAlertAction(title: "Очистить всё", style: .destructive) { [weak self] _ in
                DataManager.shared.clearList()
                DataManager.shared.clearCompletedList()
                self?.listTableView.deleteSections([0, 1], with: .fade)
                
                //self?.updateList()
                self?.updateListBadge()
            }
            alert.addAction(clearAllAction)
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        alert.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alert.popoverPresentationController {
                popoverController.barButtonItem = sender
            }
            present(alert, animated: true, completion: nil)
        } else { present(alert, animated: true) }
    }
}

// MARK: - Table view data source

extension ListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        updateTotalSumLabel()
        updateBackground()
        configureButtons()
        if items.isEmpty && completedItems.isEmpty {
            return 0
        } else if items.isEmpty || completedItems.isEmpty {
            return 1
        }
        return 2
    }
    
    func configureButtons() {
        if items.isEmpty && completedItems.isEmpty {
            clearBarButton.isEnabled = false
        } else {
            clearBarButton.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = items.count
        if section == 1 || items.isEmpty { numberOfRows = completedItems.count }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseHeaderID) as! ListHeaderCell
        var sectionTitle = Labels.ListVC.firstSectionTitle
        if section == 1 || items.isEmpty { sectionTitle = Labels.ListVC.secondSectionTitle }
        
        cell.configureCell(with: sectionTitle)
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var height: CGFloat = 74
        if section == 1 || items.isEmpty { height = 0 }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseFooterID) as! ListFooterCell
        
        totalSumLabel = cell.totalSumLabel
        updateTotalSumLabel()
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellID, for: indexPath) as! ListCell
        
        var list: [MenuItem] = items
        if indexPath.section == 1 || items.isEmpty { list = completedItems }
        
        let item = list[indexPath.row]
        var isCompleted = false
        if completedItems.contains(where: {$0 === item}) { isCompleted = true }
        cell.configureCell(with: item, isCompleted: isCompleted, listDelegate: self)
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            if self.items.isEmpty {
                DataManager.shared.removeItemFromCompletedList(at: indexPath.row)
                if self.completedItems.isEmpty {
                    self.listTableView.deleteSections([0], with: .fade)
                } else { self.listTableView.deleteRows(at: [indexPath], with: .left)}
            } else if indexPath.section == 0 {
                DataManager.shared.setNewCountFor(item: self.items[indexPath.row], count: 0)
                if self.items.isEmpty {
                    self.listTableView.deleteSections([0], with: .fade)
                } else { self.listTableView.deleteRows(at: [indexPath], with: .left)}
            } else if indexPath.section == 1 {
                DataManager.shared.removeItemFromCompletedList(at: indexPath.row)
                if self.completedItems.isEmpty {
                    self.listTableView.deleteSections([1], with: .fade)
                } else { self.listTableView.deleteRows(at: [indexPath], with: .left)}
            }
            
            self.updateListBadge()
            self.updateTotalSumLabel()

            success(true)
        })

        deleteAction.title = "Удалить"
        
        
        let completeAction = UIContextualAction(style: .destructive, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            if self.items.isEmpty {
                self.removeFromCompleted(completedItem: (self.completedItems[indexPath.row]))
            } else if indexPath.section == 0 {
                self.addToCompleted(item: (self.items[indexPath.row]))
            } else if indexPath.section == 1 {
                self.removeFromCompleted(completedItem: (self.completedItems[indexPath.row]))
            }
            
            success(true)
        })
        
        completeAction.title = "Куплено"
        if items.isEmpty || indexPath.section == 1 {
            completeAction.title = "Купить"
        }
        
        completeAction.backgroundColor = .systemGreen

        return UISwipeActionsConfiguration(actions: [completeAction, deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 && !items.isEmpty else { return }
        TapticFeedback.shared.tapticFeedback(.light)
        let storyboard = UIStoryboard(name: "MenuDetail", bundle: nil)
            
        guard let menuDetailVC = storyboard.instantiateViewController(withIdentifier: "MenuDetail") as? MenuDetailVC else { return }
        menuDetailVC.item = self.items[indexPath.row]
        menuDetailVC.indexPath = indexPath
        menuDetailVC.updateCellDelegate = self

        self.present(menuDetailVC, animated: true, completion: nil)
    }
}

// MARK: - Updationg ListCell delegate

extension ListVC: UpdatingListCellDelegate {

    func updateList() {
        for index in 0..<items.count {
            if items[index].count == 0 {
                DataManager.shared.setNewCountFor(item: items[index], count: 0)
                if items.isEmpty {
                    listTableView.deleteSections([0], with: .fade)
                } else { listTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .middle) }
                return
             }
        }

        self.listTableView.reloadData()
    }
    
    func updateListBadge() {
        let badgeValue = DataManager.shared.getValueForListBadge()
        updateListVCBadge(with: badgeValue)
    }
    
    func addToCompleted(item: MenuItem) {
        
        let completedItem = MenuItem(menuItem: item)
        
        DataManager.shared.addToCompletedList(item: completedItem)
        if completedItems.count == 1 {
            listTableView.insertSections([1], with: .automatic)
        } else { listTableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .left) }
        
        guard let index = items.firstIndex(where: {$0 === item}) else { return }
        DataManager.shared.setNewCountFor(item: item, count: 0)
        if items.isEmpty {
            listTableView.deleteSections([0], with: .fade)
        } else { listTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left) }
        
        updateListBadge()
        updateTotalSumLabel()
    }
    
    func removeFromCompleted(completedItem: MenuItem) {
        
        guard let index = DataManager.shared.getItems().firstIndex(where: {$0.name == completedItem.name}) else { return }
        let item = DataManager.shared.getItems()[index]
        
        if !(items.contains(where: {$0.name == completedItem.name })) {
            DataManager.shared.setNewCountFor(item: item, count: completedItem.count)
            item.selectedMeasurment = completedItem.selectedMeasurment
            if items.count == 1 {
                listTableView.insertSections([0], with: .left)
            } else { listTableView.insertRows(at: [IndexPath(row: (items.count - 1), section: 0)], with: .left) }
        } else if items.contains(where: {$0.name == completedItem.name && $0.selectedMeasurment == completedItem.selectedMeasurment}) {
            DataManager.shared.setNewCountFor(item: item, count: item.count + completedItem.count)
            guard let indexAtList = items.firstIndex(where: {$0.name == completedItem.name}) else { return }
            listTableView.reloadRows(at: [IndexPath(row: indexAtList, section: 0)], with: .left)
        }
        
        guard let completedIndex = completedItems.firstIndex(where: {$0 === completedItem}) else { return }
        DataManager.shared.removeItemFromCompletedList(at: completedIndex)
        if completedItems.isEmpty {
            listTableView.deleteSections([1], with: .fade)
        } else { listTableView.deleteRows(at: [IndexPath(row: completedIndex, section: 1)], with: .left) }
        
        updateListBadge()
        updateTotalSumLabel()
    }
}

// MARK: - Updationg MenuCell delegate

extension ListVC: UpdatingMenuDetailVCDelegate {
    func updateListVCBadge() {
        updateListBadge()
    }
    
    func updateFavorites() {
        DataManager.shared.updateFavorites()
    }
    
    func updateCellAt(indexPath: IndexPath?) {
        updateList()
    }
}

extension ListVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

