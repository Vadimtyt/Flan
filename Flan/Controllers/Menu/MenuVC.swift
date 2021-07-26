//
//  MenuVC.swift
//  Flan
//
//  Created by Вадим on 01.04.2021.
//

import UIKit
import Network

private let reuseSectionID = "MenuSectionCell"
private let reuseCellID = "MenuCell"

class MenuVC: UITableViewController {
    
    var categories: [(category: String, items: [MenuItem])] { get { return ListOfMenuItems.shared.categories }}
    var items: [MenuItem] { get { return ListOfMenuItems.shared.items } }
    
    var networkCheck = NetworkCheck.sharedInstance()
    
    let searchController = UISearchController(searchResultsController: nil)
    private var filtredItems: [MenuItem] = []
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    var isKeyboardPresented = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: reuseSectionID, bundle: nil), forCellReuseIdentifier: MenuSectionCell.reuseId)
        tableView.register(UINib(nibName: reuseCellID, bundle: nil), forCellReuseIdentifier: MenuCell.reuseId)
        
        configureSearchController()
        configureNavigationBarLargeStyle()
        tableView.showsVerticalScrollIndicator = false
        self.definesPresentationContext = true
        tableView.backgroundColor = .groupTableViewBackground
        tableView.separatorStyle = .none
        
        checkNetworkConnecion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkNetworkConnecion()
        DispatchQueue.main.async {
                self.tableView.reloadData()
        }
    }
    
    func checkNetworkConnecion() {
        if networkCheck.currentStatus == .satisfied{
            //Do nothing
        } else if networkCheck.currentStatus == .unsatisfied {
            statusDidChange(status: networkCheck.currentStatus)
        }
        networkCheck.addObserver(observer: self)
    }
    
    func configureSearchController() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification,
                                               object:nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification,
                                               object:nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MenuVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Введите название"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        isKeyboardPresented = true
    }


    @objc func keyboardDidHide(notification: NSNotification) {
        isKeyboardPresented = false
    }
    
    @objc func dismissKeyboard() {
        self.searchController.searchBar.endEditing(true)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        }
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseSectionID) as! MenuSectionCell
        cell.configureCell(with: categories[section].category)
        return cell.contentView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isFiltering {
            return 0
        }
        return 60
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return nil
        }
        return categories[section].category
    }
    
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 30
//    }
//
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = .white
//        return view
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredItems.count
        }
        return categories[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellID, for: indexPath) as! MenuCell
        var item = MenuItem(name: "Имя", category: "Категория", prices: [0], measurements: [""], imageName: "Кекс")
        
        if isFiltering {
            item = filtredItems[indexPath.row]
        } else { item = categories[indexPath.section].items[indexPath.row] }
        
        cell.configureCell(with: item)
        cell.updateCellDelegate = self
 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isKeyboardPresented else { return }
        let storyboard = UIStoryboard(name: "MenuDetail", bundle: nil)
            
        guard let menuDetailVC = storyboard.instantiateViewController(withIdentifier: "MenuDetail") as? MenuDetailVC else { return }
        if isFiltering {
            menuDetailVC.item = self.filtredItems[indexPath.row]
        } else {
            menuDetailVC.item = self.categories[indexPath.section].items[indexPath.row]
        }
        menuDetailVC.indexPath = indexPath
        menuDetailVC.updateCellDelegate = self

        self.present(menuDetailVC, animated: true, completion: nil)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isKeyboardPresented { dismissKeyboard() }
    }
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        searchController.isActive = true
    }
    
    @IBAction func categoriesButtonPressed(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: "Categories", bundle: nil)
        
        guard let categoriesVC = storyboard.instantiateViewController(withIdentifier: "Categories") as? CategoriesVC else { return }
        
        categoriesVC.categoriesVCDelegate = self
        categoriesVC.modalPresentationStyle = .custom
        categoriesVC.categories = categories
        categoriesVC.transitioningDelegate = self
        self.present(categoriesVC, animated: true, completion: nil)
    }
}

extension MenuVC: NetworkCheckObserver {
    
    func statusDidChange(status: NWPath.Status) {
        if status == .satisfied {
            //Do nothing
        }else if status == .unsatisfied {
            showNetworkAlert(title: "Упс...", message: "Кажется пропало соединение с интернетом. Пожалуйста, проверьте wi-fi или сотовую связь")
        }
    }
}

extension MenuVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String){
        //Uncomment to change filter strategy
        //filtredItems = items.filter{ $0.name.lowercased().contains(searchText.lowercased()) }
        //filtredItems = items.filter{ $0.name.lowercased().hasPrefix(searchText.lowercased()) }
        
        filtredItems = items.filter{
            var isFits: [Bool] = []
            let itemWords = $0.name.lowercased().components(separatedBy: [" ", ".", ","])
            let searchingWords = searchText.lowercased().components(separatedBy: [" ", "."])
            
            searchingWords.forEach {
                var isThisSearchWordFits = false
                for word in itemWords {
                    if word.hasPrefix($0) { isThisSearchWordFits = true }
                }
                isFits.append(isThisSearchWordFits)
            }
            
            return !(isFits.contains(false))
        }
        
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filtredItems = []
        }
        
        tableView.reloadData()
        if !(filtredItems.isEmpty) {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}

extension MenuVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
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
    
    func updateCellAt(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension MenuVC: CategoriesVCDelegate{
    func scrollTableToRow(at indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}
