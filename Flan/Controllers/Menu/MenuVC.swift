//
//  MenuVC.swift
//  Flan
//
//  Created by Вадим on 01.04.2021.
//

import UIKit

private let reuseIdentifier = "MenuCell"

class MenuVC: UITableViewController {
    let names: Set = ["Пирожок", "Слойка", "Пицца", "Торт", "Коктейль", "Киш", "Кекс"]
    
    var items: [MenuItem] = ListOfMenuItems.shared.items
    
    let searchController = UISearchController(searchResultsController: nil)
    private var filtredItems: [MenuItem] = []
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: MenuCell.reuseId)
        ListOfMenuItems.shared.items = generateItems(count: Int.random(in: 5...20))
        items = ListOfMenuItems.shared.items
        
        configureSearchController()
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
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
    
    func configureSearchController() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MenuVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredItems.count
        }
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MenuCell
        var item = MenuItem(name: "Имя", price: 0)
        
        if isFiltering {
            item = filtredItems[indexPath.row]
        } else { item = items[indexPath.row] }
        
        cell.configureCell(with: item)
        cell.UpdateCellDelegate = self
 
        return cell
    }
    
    func generateItem() -> MenuItem {
        return MenuItem(name: names.randomElement() ?? "Error", price: Int.random(in: 100...500))
    }
    
    func generateItems(count: Int) -> [MenuItem] {
        var items: [MenuItem] = []
        
        for _ in 0...count {
            let newItem = generateItem()
            items.append(newItem)
        }
        
        return items
    }
}

extension MenuVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String){
        filtredItems = items.filter({ (MenuItem: MenuItem) -> Bool in
            return MenuItem.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    @objc func dismissKeyboard() {
        self.searchController.searchBar.endEditing(true)
    }
}

extension MenuVC: UpdatingMenuCellDelegate {
    func updateListVCBadge() {
        let badgeValue = ListOfMenuItems.shared.getValueForListBadge()
        updateListVCBadge(with: badgeValue)
    }
    
    func updateFavorites() {
        ListOfMenuItems.shared.updateFavorites()
    }
}
