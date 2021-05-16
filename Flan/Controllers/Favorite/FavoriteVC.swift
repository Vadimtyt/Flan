//
//  FavoriteVC.swift
//  Flan
//
//  Created by Вадим on 20.02.2021.
//

import UIKit

private let reuseIdentifier = "MenuCell"

class FavoriteVC: UITableViewController {
    private let indexOfListVC = 2
    
    var items: [MenuItem] = ListOfMenuItems.shared.favorites

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        
        tableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: MenuCell.reuseId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateFavoriteVC()
    }
    
    func configureNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 13.0, *) {
            let largeStyle = UINavigationBarAppearance()
            largeStyle.configureWithTransparentBackground()
            largeStyle.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 42)]
            self.navigationController?.navigationBar.scrollEdgeAppearance = largeStyle
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MenuCell
 
        let item = items[indexPath.row]
        cell.configureCell(with: item)
        cell.FavoriteVCDelegate = self
 
        return cell
    }
}

extension FavoriteVC: FavoriteVCDelegate {
    func updateListBadge() {
        let badgeValue = ListOfMenuItems.shared.getValueForListBadge()
        updateListVCBadge(with: badgeValue)
    }
    
    func updateFavoriteVC() {
        items = ListOfMenuItems.shared.favorites
        for index in 0..<items.count {
            if items[index].isFavorite == false {
                ListOfMenuItems.shared.favorites.remove(at: index)
                items = ListOfMenuItems.shared.favorites
                tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .middle)
                return
             }
        }
        
        self.tableView.reloadData()
    }
}
