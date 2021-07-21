//
//  FavoriteVC.swift
//  Flan
//
//  Created by Вадим on 20.02.2021.
//

import UIKit

private let reuseIdentifier = "MenuCell"

class FavoriteVC: UITableViewController {
    
    var items: [MenuItem] { get { return ListOfMenuItems.shared.favorites } }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: MenuCell.reuseId)
        
        configureNavigationBarLargeStyle()
        tableView.showsVerticalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateBackgound()
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MenuCell
 
        let item = items[indexPath.row]
        cell.configureCell(with: item)
        cell.updateCellDelegate = self
 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "MenuDetail", bundle: nil)
            
        guard let menuDetailVC = storyboard.instantiateViewController(withIdentifier: "MenuDetail") as? MenuDetailVC else { return }
        menuDetailVC.item = self.items[indexPath.row]
        menuDetailVC.indexPath = indexPath
        menuDetailVC.updateCellDelegate = self

        self.present(menuDetailVC, animated: true, completion: nil)
    }
    
    func updateBackgound() {
        if items.isEmpty {
            tableView.setEmptyView(title: "Пусто",
                                   message: "Чтобы добавить свою вкусняшку в избранное нажмите на сердечко в углу её изображения",
                                   messageImage: UIImage(named: "emptyList.png")!)
            tableView.isScrollEnabled = false
        } else {
            tableView.restore()
            tableView.isScrollEnabled = true
        }
    }
}

extension FavoriteVC: UpdatingMenuCellDelegate {
    func updateListVCBadge() {
        let badgeValue = ListOfMenuItems.shared.getValueForListBadge()
        updateListVCBadge(with: badgeValue)
    }
    
    func updateFavorites() {
        if let index = items.firstIndex(where: { $0.isFavorite == false }) {
            ListOfMenuItems.shared.favorites.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
            return
        }
        ListOfMenuItems.shared.updateFavorites()
        
        self.tableView.reloadData()
    }
    
    func updateCellAt(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
