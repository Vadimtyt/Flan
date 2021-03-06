//
//  FavoriteVC.swift
//  Flan
//
//  Created by Вадим on 20.02.2021.
//

import UIKit

private let reuseIdentifier = "MenuCell"

class FavoriteVC: UITableViewController {
    
    // MARK: - Props
    
    private var items: [MenuItem] { DataManager.shared.getFavorites() }
    private var isFirstAppearance = true

    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: MenuCell.reuseId)
        
        configureNavigationBarLargeStyle()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isFirstAppearance {
            tableView.reloadData()
        } else { isFirstAppearance = false }
    }
    
    // MARK: - Funcs
    
    private func setupTableView() {
        tableView.backgroundColor = .groupTableViewBackground
        tableView.separatorStyle = .none
    }

    private func updateBackgound() {
        if items.isEmpty {
            tableView.setEmptyView(title: Labels.FavoriteVC.emptyViewTitle,
                                   message: Labels.FavoriteVC.emptyViewMessage,
                                   messageImage: UIImage(named: "emptyFavorites.png"))
            tableView.isScrollEnabled = false
        } else {
            tableView.restore()
            tableView.isScrollEnabled = true
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateBackgound()
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(142)
        if UIDevice.current.userInterfaceIdiom == .pad {
            height = 168
        }
        return height
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MenuCell
 
        let item = items[indexPath.row]
        cell.configureCell(with: item)
        cell.updateCellDelegate = self
 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TapticFeedback.shared.tapticFeedback(.light)
        let storyboard = UIStoryboard(name: "MenuDetail", bundle: nil)
            
        guard let menuDetailVC = storyboard.instantiateViewController(withIdentifier: "MenuDetail") as? MenuDetailVC else { return }
        menuDetailVC.item = self.items[indexPath.row]
        menuDetailVC.indexPath = indexPath
        menuDetailVC.updateCellDelegate = self

        self.present(menuDetailVC, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeAction = UIContextualAction(style: .destructive, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            DataManager.shared.removeFromFavorites(item: self.items[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .left)
            self.updateFavorites()

            success(true)
        })

        removeAction.title = "Убрать"
        removeAction.image = UIImage(named: "heart.slash.fill")

        return UISwipeActionsConfiguration(actions: [removeAction])
    }
}

// MARK: - Updating MenuCell delegate

extension FavoriteVC: UpdatingMenuCellDelegate {
    
    func updateListVCBadge() {
        let badgeValue = DataManager.shared.getValueForListBadge()
        updateListVCBadge(with: badgeValue)
    }
    
    func updateFavorites() {
        if let index = items.firstIndex(where: { $0.isFavorite == false }) {
            DataManager.shared.removeFromFavorites(item: items[index])
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
            return
        }
        DataManager.shared.updateFavorites()
        
        self.tableView.reloadData()
    }
}

extension FavoriteVC: UpdatingMenuDetailVCDelegate {
    func updateCellAt(indexPath: IndexPath?) {
        if let indexPath = indexPath {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else { tableView.reloadData() }
    }
}
