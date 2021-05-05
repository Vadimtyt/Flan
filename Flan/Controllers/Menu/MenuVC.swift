//
//  MenuVC.swift
//  Flan
//
//  Created by Вадим on 01.04.2021.
//

import UIKit

private let reuseIdentifier = "MenuCell"

class MenuVC: UITableViewController, MenuVCDelegate {
    
    let names: Set = ["Пирожок", "Слойка", "Пицца", "Торт", "Коктейль", "Киш", "Кекс"]
    
    private let indexOfListVC = 2
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
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = false
        
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func configureNavigationBar() {
        if #available(iOS 13.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            let largeStyle = UINavigationBarAppearance()
            largeStyle.configureWithTransparentBackground()
            largeStyle.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 42)]
            self.navigationController?.navigationBar.scrollEdgeAppearance = largeStyle
        }
    }
    
    func updateListBadge() {
        let items = ListOfMenuItems.shared.list
        var sumCountOfItems = 0
        
        for item in items {
            if item.count != 0 {
                sumCountOfItems += item.count
            }
        }
        
        if sumCountOfItems != 0 {
            self.navigationController?.tabBarController?.tabBar.items?[indexOfListVC].badgeValue = "\(sumCountOfItems)"
        } else if sumCountOfItems == 0 {
            self.navigationController?.tabBarController?.tabBar.items?[indexOfListVC].badgeValue = nil
        }
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
        cell.MenuVCDelegate = self
 
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
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
}
