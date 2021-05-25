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
    
    var items: [MenuItem] { get { return ListOfMenuItems.shared.items } }
    
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
        ListOfMenuItems.shared.items = generateItems(count: Int.random(in: 30...50))
        
        configureSearchController()
        configureNavigationBarLargeStyle()
        tableView.showsVerticalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func configureSearchController() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MenuVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Введите название"
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
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        searchController.isActive = true
    }
}

extension MenuVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String){
        //Uncomment to change filter strategy
        //filtredItems = items.filter{ $0.name.lowercased().contains(searchText.lowercased()) }
        
        filtredItems = items.filter{ $0.name.lowercased().hasPrefix(searchText.lowercased()) }
        
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
