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
    
    private var list: [MenuItem] { DataManager.shared.getList() }
    private var completedList: [MenuItem] { get { return DataManager.shared.getCompletedList() } }

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
        listTableView.reloadData()
    }
    
    // MARK: - Funcs
    
    private func setupTableView() {
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.separatorStyle = .none
        listTableView.register(UINib(nibName: reuseCellID, bundle: nil), forCellReuseIdentifier: ListCell.reuseId)
        listTableView.register(UINib(nibName: reuseHeaderID, bundle: nil), forCellReuseIdentifier: ListHeaderCell.reuseId)
        listTableView.register(UINib(nibName: reuseFooterID, bundle: nil), forCellReuseIdentifier: ListFooterCell.reuseId)
        
        if #available(iOS 15.0, *) {
            listTableView.sectionHeaderTopPadding = 0
        }
    }
    
    private func getTotalSum() -> Int {
        var newSum = 0
        for item in list {
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
        if list.isEmpty && completedList.isEmpty {
            listTableView.setEmptyView(title: Labels.ListVC.emptyViewTitle,
                                       message: Labels.ListVC.emptyViewMessage,
                                       messageImage: UIImage(named: "emptyList.png"))
        } else { listTableView.restore() }
    }
    
    private func getTextList() -> String {
        var text = "Список покупок во Флане:\n"
        for item in list {
            let name = item.name,
                count = item.count,
                measurment = item.measurements[item.selectedMeasurment],
                price = item.prices[item.selectedMeasurment]
            
            text += "- \(name)\n      \(count) * \(measurment)/\(price)₽,\n"
        }
        text.removeLast()
        text.removeLast()
        let totalSum = "Примерная сумма: " + String(getTotalSum()) + "₽"
        text += "\n" + totalSum
        return text
    }
    
    // MARK: - @IBActions
    
    @IBAction private func infoButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)

        let popUpWidth: CGFloat = 288
        let popUpHeight: CGFloat = 163

        var arrowY: CGFloat = 0
        let rectOfCell = listTableView.rectForRow(at: IndexPath(row: list.count - 1, section: 0))
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
        popover.sourceRect = CGRect(x: sender.bounds.minX - 21,
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
        if !(list.isEmpty) {
            let clearBuyAction = UIAlertAction(title: "Очистить список Купить", style: .destructive) { [weak self] _ in
                for item in DataManager.shared.getList() {
                    item.count = 0
                }
                DataManager.shared.clearList()
                self?.listTableView.deleteSections([0], with: .fade)
                self?.updateListVCBadgeAndTotalSum()
            }
            alert.addAction(clearBuyAction)
        }
        
        // Crear buyed action
        if !(completedList.isEmpty) {
            let clearBuyedAction = UIAlertAction(title: "Очистить список Куплено", style: .destructive) { [weak self] _ in
                DataManager.shared.clearCompletedList()
                guard let sectionsCount = self?.listTableView.numberOfSections else { return }
                self?.listTableView.deleteSections([sectionsCount - 1], with: .fade)
                self?.updateListVCBadgeAndTotalSum()
            }
            alert.addAction(clearBuyedAction)
        }
        
        // Crear all action
        if !(list.isEmpty || completedList.isEmpty) {
            let clearAllAction = UIAlertAction(title: "Очистить всё", style: .destructive) { [weak self] _ in
                DataManager.shared.clearList()
                DataManager.shared.clearCompletedList()
                self?.listTableView.deleteSections([0, 1], with: .fade)
                self?.updateListVCBadgeAndTotalSum()
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
        if list.isEmpty && completedList.isEmpty {
            return 0
        } else if list.isEmpty || completedList.isEmpty {
            return 1
        }
        return 2
    }
    
    func configureButtons() {
        if list.isEmpty && completedList.isEmpty {
            clearBarButton.isEnabled = false
        } else {
            clearBarButton.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = list.count
        if section == 1 || list.isEmpty { numberOfRows = completedList.count }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseHeaderID) as! ListHeaderCell
        var sectionTitle = Labels.ListVC.firstSectionTitle
        if section == 1 || list.isEmpty { sectionTitle = Labels.ListVC.secondSectionTitle }
        
        cell.configureCell(with: sectionTitle)
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var height: CGFloat = 74
        if section == 1 || list.isEmpty { height = 0 }
        
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
        
        var listOfItems: [MenuItem] = list
        if indexPath.section == 1 || list.isEmpty { listOfItems = completedList }
        
        let item = listOfItems[indexPath.row]
        var isCompleted = false
        if completedList.contains(where: {$0 === item}) { isCompleted = true }
        cell.configureCell(with: item, isCompleted: isCompleted, listDelegate: self)
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            if indexPath.section == 1 || self.list.isEmpty {
                DataManager.shared.removeItemFromCompletedList(at: indexPath.row)
            } else if indexPath.section == 0 {
                DataManager.shared.setNewCountFor(item: self.list[indexPath.row], count: 0)
            }
            
            self.removeRow(at: indexPath)
            self.updateListVCBadgeAndTotalSum()

            success(true)
        })

        deleteAction.title = "Удалить"
        
        
        let completeAction = UIContextualAction(style: .destructive, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            if indexPath.section == 1 || self.list.isEmpty {
                self.removeFromCompleted(completedItem: (self.completedList[indexPath.row]))
            } else if indexPath.section == 0 {
                self.addToCompleted(item: (self.list[indexPath.row]))
            }
            
            success(true)
        })
        
        completeAction.title = "Куплено"
        if list.isEmpty || indexPath.section == 1 {
            completeAction.title = "Купить"
        }
        
        completeAction.backgroundColor = .systemGreen

        return UISwipeActionsConfiguration(actions: [completeAction, deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 && !list.isEmpty else { return }
        TapticFeedback.shared.tapticFeedback(.light)
        let storyboard = UIStoryboard(name: "MenuDetail", bundle: nil)
            
        guard let menuDetailVC = storyboard.instantiateViewController(withIdentifier: "MenuDetail") as? MenuDetailVC else { return }
        menuDetailVC.item = self.list[indexPath.row]
        menuDetailVC.indexPath = indexPath
        menuDetailVC.updateCellDelegate = self

        self.present(menuDetailVC, animated: true, completion: nil)
    }
}

// MARK: - Updationg ListCell delegate

extension ListVC: UpdatingListCellDelegate {
    func removeRow(at indexPath: IndexPath) {
        if listTableView.numberOfRows(inSection: indexPath.section) == 1 {
            listTableView.deleteSections([indexPath.section], with: .fade)
        } else {
            listTableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .left)
        }
    }
    
    func updateListVCBadgeAndTotalSum() {
        let badgeValue = DataManager.shared.getValueForListBadge()
        updateListVCBadge(with: badgeValue)
        updateTotalSumLabel()
    }
    
    func addToCompleted(item: MenuItem) {
        let completedItem = MenuItem(menuItem: item)
        
        DataManager.shared.addToCompletedList(item: completedItem)
        if completedList.count == 1 {
            listTableView.insertSections([1], with: .automatic)
        } else { listTableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .left) }
        
        guard let index = list.firstIndex(where: {$0 === item}) else { return }
        DataManager.shared.setNewCountFor(item: item, count: 0)
        removeRow(at: IndexPath(row: index, section: 0))
        
        updateListVCBadgeAndTotalSum()
    }
    
    func removeFromCompleted(completedItem: MenuItem) {
        guard let index = DataManager.shared.getItems().firstIndex(where: {$0.name == completedItem.name}) else { return }
        let item = DataManager.shared.getItems()[index]
        
        if !(list.contains(where: {$0.name == completedItem.name })) {
            DataManager.shared.setNewCountFor(item: item, count: completedItem.count)
            item.selectedMeasurment = completedItem.selectedMeasurment
            if list.count == 1 {
                listTableView.insertSections([0], with: .left)
            } else { listTableView.insertRows(at: [IndexPath(row: (list.count - 1), section: 0)], with: .left) }
        } else if list.contains(where: {$0.name == completedItem.name && $0.selectedMeasurment == completedItem.selectedMeasurment}) {
            DataManager.shared.setNewCountFor(item: item, count: item.count + completedItem.count)
            guard let indexAtList = list.firstIndex(where: {$0.name == completedItem.name}) else { return }
            listTableView.reloadRows(at: [IndexPath(row: indexAtList, section: 0)], with: .left)
        }
        
        guard let completedIndex = completedList.firstIndex(where: {$0 === completedItem}) else { return }
        DataManager.shared.removeItemFromCompletedList(at: completedIndex)
        removeRow(at: IndexPath(row: completedIndex, section: 1))
        
        updateListVCBadgeAndTotalSum()
    }
}

// MARK: - Updationg MenuCell delegate

extension ListVC: UpdatingMenuDetailVCDelegate {
    func updateListVCBadge() {
        updateListVCBadgeAndTotalSum()
    }
    
    func updateFavorites() {
        DataManager.shared.updateFavorites()
    }
    
    func updateCellAt(indexPath: IndexPath?) {
        listTableView.reloadData()
    }
}

extension ListVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

