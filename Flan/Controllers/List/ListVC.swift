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
    
    var items: [MenuItem] { get { return ListOfMenuItems.shared.list } }
    var completedItems: [MenuItem] = []
    
    private let popUpText = "В этом поле указывается приблизительная сумма, она не учитывает фактический вес всех позиций, цену упаковочных изделий и т.п. Эта сумма отображается исключительно в ознакомительных целях."
    private let popUpTextFontSize: CGFloat = 18
    
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var clearBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        changeTotalSumLabel()
        updateBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateList()
    }
    
    func setupTableView() {
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.showsVerticalScrollIndicator = false
        listTableView.separatorInset = .zero
        listTableView.separatorColor = listTableView.backgroundColor
        listTableView.register(UINib(nibName: reuseCellID, bundle: nil), forCellReuseIdentifier: ListCell.reuseId)
        listTableView.register(UINib(nibName: reuseHeaderID, bundle: nil), forCellReuseIdentifier: ListHeaderCell.reuseId)
        listTableView.register(UINib(nibName: reuseFooterID, bundle: nil), forCellReuseIdentifier: ListFooterCell.reuseId)
    }
    
    func getTotalSum() -> Int {
        var newSum = 0
        for item in items {
            newSum += (item.prices[item.selectedMeasurment]) * item.count
        }
        
        return newSum
    }
    
    func changeTotalSumLabel() {

//        if newSum == 0 {
//            totalSumLabel.text = "Итого: 0Р"
//        } else { totalSumLabel.text = "Итого: ≈\(newSum)Р" }

    }
    
    func updateBackground() {
        if items.isEmpty && completedItems.isEmpty {
            listTableView.setEmptyView(title: "Пусто", message: "Добавьте что-нибудь в список", messageImage: UIImage(named: "emptyList.png")!)
        } else { listTableView.restore() }
    }
    
    func getTextList() -> String {
        var list = "Весь список:"
        for item in items {
            list += "\n\(item.name) - \(item.count) шт.,"
        }
        list.removeLast()
        let sum = String(getTotalSum())
        list += "\n" + sum
        return list
    }
    
    func clearListAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Crear buy action
        if !(items.isEmpty) {
            let clearBuyAction = UIAlertAction(title: "Очистить список Купить", style: .destructive) { [weak self] _ in
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
        if !(completedItems.isEmpty) {
            let clearBuyedAction = UIAlertAction(title: "Очистить список Куплено", style: .destructive) { [weak self] _ in
                self?.completedItems.removeAll()
                
                self?.updateList()
                self?.updateListBadge()
            }
            alert.addAction(clearBuyedAction)
        }
        
        // Crear all action
        if !(items.isEmpty || completedItems.isEmpty) {
            let clearAllAction = UIAlertAction(title: "Очистить всё", style: .destructive) { [weak self] _ in
                ListOfMenuItems.shared.clearList()
                self?.completedItems.removeAll()
                
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

        var textTopConstraint: CGFloat = 6
        let popUpWidth: CGFloat = 294
        let popUpHeight: CGFloat = 163

        var arrowY: CGFloat = 0
        let rectOfCell = listTableView.rectForRow(at: IndexPath(row: items.count - 1, section: 0))
        let rectOfCellInSuperview = listTableView.convert(rectOfCell, to: listTableView.superview)
        if rectOfCellInSuperview.maxY < popUpHeight {
            arrowY = sender.bounds.maxY
            textTopConstraint = 16
        } else {
            arrowY = sender.bounds.minY
        }

        let vc = InfoPopover(text: popUpText, fontSize: popUpTextFontSize, topConstraint: textTopConstraint)
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
        changeTotalSumLabel()
        updateBackground()
        configureButtons()
        if items.isEmpty && completedItems.isEmpty {
            return 0
        }
        return 2
    }
    
    func configureButtons() {
        if items.isEmpty && completedItems.isEmpty {
            clearBarButton.isEnabled = false
//            infoButton.isHidden = true
//            shareButton.isHidden = true
//            totalSumLabel.isHidden = true
        } else {
            clearBarButton.isEnabled = true
//            infoButton.isHidden = false
//            shareButton.isHidden = false
//            totalSumLabel.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        if section == 0 {
            numberOfRows = items.count
        } else if section == 1 { numberOfRows = completedItems.count}
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseHeaderID) as! ListHeaderCell
        var sectionTitle = ""
        if section == 0 {
            sectionTitle = "Купить"
        } else if section == 1 { sectionTitle = "Куплено" }
        
        cell.configureCell(with: sectionTitle)
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var height: CGFloat = 0
        if section == 0 {
            height = 66
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseFooterID) as! ListFooterCell
        let totalSum = getTotalSum()
        cell.configureCellWith(totalSum: totalSum, listDelegate: self)
        
        return cell.contentView
    }
    
    func invalidateSupplementaryElements(ofKind elementKind: String, at indexPaths: [IndexPath]) {
        //kind = UICollectionElementKindSectionFooter
    }

    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        var sectionTitle = ""
//        if section == 0 {
//            sectionTitle = "Купить"
//        } else if section == 1 { sectionTitle = "Куплено" }
//        return sectionTitle
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellID, for: indexPath) as! ListCell
        
        var list: [MenuItem] = []
        if indexPath.section == 0 {
            list = items
        } else if indexPath.section == 1 { list = completedItems }
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
                self.completedItems.remove(at: indexPath.row)
            }
            if self.items.isEmpty && self.completedItems.isEmpty {
                self.listTableView.deleteSections([0, 1], with: .top)
            } else { tableView.deleteRows(at: [indexPath], with: .left) }
            
            self.updateListBadge()
            self.updateList()

            success(true)
        })

        deleteAction.title = "Удалить"
        
        
        let completeAction = UIContextualAction(style: .destructive, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            if indexPath.section == 0 {
                self.addToCompleted(item: (self.items[indexPath.row]))
            } else if indexPath.section == 1 {
                self.removeFromCompleted(completedItem: (self.completedItems[indexPath.row]))
            }
            
            success(true)
        })
        
        if indexPath.section == 0 {
            completeAction.title = "Куплено"
        } else if indexPath.section == 1 {
            completeAction.title = "Купить"
        }
        
        completeAction.backgroundColor = .systemGreen

        return UISwipeActionsConfiguration(actions: [completeAction, deleteAction])
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
                if items.isEmpty && completedItems.isEmpty {
                    listTableView.deleteSections([0, 1], with: .top)
                } else { listTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .middle) }
                return
             }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.listTableView.reloadData()
        }
    }
    
    func updateListBadge() {
        let badgeValue = ListOfMenuItems.shared.getValueForListBadge()
        updateListVCBadge(with: badgeValue)
    }
    
    func addToCompleted(item: MenuItem) {
        
        let completedItem = MenuItem(item: item)
        
        completedItems.insert(completedItem, at: 0)
        listTableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .left)
        
        guard let index = items.firstIndex(where: {$0 === item}) else { return }
        ListOfMenuItems.shared.removeFromList(item: item)
        listTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
        
        updateListBadge()
        updateList()
    }
    
    func removeFromCompleted(completedItem: MenuItem) {
        
        guard let index = ListOfMenuItems.shared.items.firstIndex(where: {$0.name == completedItem.name}) else { return }
        let item = ListOfMenuItems.shared.items[index]
        
        if !(items.contains(where: {$0.name == completedItem.name })) {
            item.count = completedItem.count
            item.selectedMeasurment = completedItem.selectedMeasurment
            ListOfMenuItems.shared.addToList(item: item)
            listTableView.insertRows(at: [IndexPath(row: (items.count - 1), section: 0)], with: .left)
        } else if items.contains(where: {$0.name == completedItem.name && $0.selectedMeasurment == completedItem.selectedMeasurment}) {
            item.count += completedItem.count
            guard let indexAtList = items.firstIndex(where: {$0.name == completedItem.name}) else { return }
            listTableView.reloadRows(at: [IndexPath(row: indexAtList, section: 0)], with: .left)
        }
        
        guard let completedIndex = completedItems.firstIndex(where: {$0 === completedItem}) else { return }
        completedItems.remove(at: completedIndex)
        listTableView.deleteRows(at: [IndexPath(row: completedIndex, section: 1)], with: .left)
        
        updateListBadge()
        updateList()
    }
}

extension ListVC: UpdatingMenuCellDelegate {
    func updateListVCBadge() {
        updateListBadge()
    }
    
    func updateFavorites() {
        ListOfMenuItems.shared.updateFavorites()
    }
    
    func updateCellAt(indexPath: IndexPath) {
        updateList()
    }
    
    
}

extension ListVC: UpdatingListFooterDelegate {
    func footerInfoButtonPressed(button: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        var textTopConstraint: CGFloat = 6
        let popUpWidth: CGFloat = 294
        let popUpHeight: CGFloat = 163
        
        var arrowY: CGFloat = 0
        let rectOfCell = listTableView.rectForRow(at: IndexPath(row: items.count - 1, section: 0))
        let rectOfCellInSuperview = listTableView.convert(rectOfCell, to: listTableView.superview)
        if rectOfCellInSuperview.maxY < popUpHeight {
            arrowY = button.bounds.maxY
            textTopConstraint = 20
        } else {
            arrowY = button.bounds.minY
        }
        
        let vc = InfoPopover(text: popUpText, fontSize: popUpTextFontSize, topConstraint: textTopConstraint)
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        
        if rectOfCellInSuperview.maxY < popUpHeight {
            popover.permittedArrowDirections = .up
        } else { popover.permittedArrowDirections = .down }
        
        popover.sourceView = button
        popover.delegate = self
        popover.sourceRect = CGRect(x: button.bounds.minX - 19,
                                    y: arrowY,
                                    width: 0,
                                    height: 0)
        
        vc.preferredContentSize = CGSize(width: popUpWidth, height: popUpHeight)
        
        present(vc, animated: true, completion:nil)
    }
    
    func shareButtonPressed() {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let message = getTextList()
        let objectsToShare = [message]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        self.present(activityVC, animated: true, completion: nil)
    }
}

extension ListVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

