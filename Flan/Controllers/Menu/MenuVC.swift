//
//  MenuVC.swift
//  Flan
//
//  Created by Вадим on 01.04.2021.
//

import UIKit
import Network

private let reuseHeaderID = "MenuHeaderCell"
private let reuseCellID = "MenuCell"

class MenuVC: UITableViewController {
    
    // MARK: - Props
    
    private var categories: [(category: String, items: [MenuItem])] { DataManager.shared.getCategories() }
    private var items: [MenuItem] { DataManager.shared.getItems() }
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var filtredItems: [MenuItem] = []
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool { searchController.isActive && !searchBarIsEmpty }
    private var isKeyboardPresented = false
    
    private var isFirstAppearance = true

    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchController()
        configureNavigationBarLargeStyle()
        configureScrollView()
        
        self.definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isFirstAppearance {
            tableView.reloadData()
        } else { isFirstAppearance = false }
        updateListVCBadge()
        updateBackgound()
    }
    
    // MARK: - Funcs
    
    private func configureTableView() {
        tableView.register(UINib(nibName: reuseHeaderID, bundle: nil), forCellReuseIdentifier: MenuHeaderCell.reuseId)
        tableView.register(UINib(nibName: reuseCellID, bundle: nil), forCellReuseIdentifier: MenuCell.reuseId)
        
        tableView.backgroundColor = .groupTableViewBackground
        tableView.separatorStyle = .none
    }
    
    private func configureSearchController() {
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
        searchController.searchBar.placeholder = Labels.MenuVC.searchPlaceholder
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
    private func configureScrollView() {
        let scrollView = self.tableView as UIScrollView
        scrollView.keyboardDismissMode = .interactive
    }
    
    private func updateBackgound() {
        if items.isEmpty {
            tableView.setEmptyView(title: Labels.MenuVC.emptyViewTitle,
                                   message: Labels.MenuVC.emptyViewMessage,
                                   messageImage: UIImage(named: "cloudError.png")!)
            tableView.isScrollEnabled = false
        } else {
            tableView.restore()
            tableView.isScrollEnabled = true
        }
    }
    
    // MARK: - @objc funcs
    
    @objc private func keyboardDidShow(notification: NSNotification) {
        isKeyboardPresented = true
    }


    @objc private func keyboardDidHide(notification: NSNotification) {
        isKeyboardPresented = false
    }
    
    @objc private func dismissKeyboard() {
        self.searchController.searchBar.endEditing(true)
    }

    // MARK: - @IBactions
    
    @IBAction private func searchButtonPressed(_ sender: UIBarButtonItem) {
        searchController.isActive = true
    }
    
    @IBAction private func categoriesButtonPressed(_ sender: UIBarButtonItem) {
        guard !(categories.isEmpty) else { return }
        
        let storyboard = UIStoryboard(name: "Categories", bundle: nil)
        
        guard let categoriesVC = storyboard.instantiateViewController(withIdentifier: "Categories") as? CategoriesVC else { return }
        
        categoriesVC.transitioningDelegate = self
        categoriesVC.categoriesVCDelegate = self
        if UIDevice.current.userInterfaceIdiom == .pad {
            categoriesVC.modalPresentationStyle = .formSheet
        } else { categoriesVC.modalPresentationStyle = .custom }
        self.present(categoriesVC, animated: true, completion: nil)
    }
}

// MARK: - TableViewDelegate, TableViewDelegate

extension MenuVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        }
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseHeaderID) as! MenuHeaderCell
        cell.configureCell(with: categories[section].category)
        return cell.contentView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isFiltering {
            return 0
        }
        return 56
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return nil
        }
        return categories[section].category
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(142)
        if UIDevice.current.userInterfaceIdiom == .pad {
            height = 168
        }
        return height
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredItems.count
        }
        return categories[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellID, for: indexPath) as! MenuCell
        var item = MenuItem()
        
        if isFiltering {
            item = filtredItems[indexPath.row]
        } else { item = categories[indexPath.section].items[indexPath.row] }
        
        cell.configureCell(with: item)
        cell.updateCellDelegate = self
 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isKeyboardPresented else { return }
        TapticFeedback.shared.tapticFeedback(.light)
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
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        //if isKeyboardPresented { dismissKeyboard() }
//    }
}

// MARK: - Search results
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
            let itemWords = $0.name.lowercased().components(separatedBy: [" ", ".", ",", "(", ")", "-"])
            let searchingWords = searchText.lowercased().components(separatedBy: [" ", ".", ",", "(", ")", "-"])
            
            searchingWords.forEach {
                var isThisSearchWordFits = false
                for itemWord in itemWords {
                    if itemWord.hasPrefix($0) { isThisSearchWordFits = true }
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

// MARK: - Updating menu cell delegate

extension MenuVC: UpdatingMenuCellDelegate {
    
    func updateListVCBadge() {
        let badgeValue = DataManager.shared.getValueForListBadge()
        updateListVCBadge(with: badgeValue)
    }
    
    func updateFavorites() {
        DataManager.shared.updateFavorites()
    }
}

extension MenuVC: UpdatingMenuDetailDelegate {
    func updateCellAt(indexPath: IndexPath?) {
        if let indexPath = indexPath {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else { tableView.reloadData() }
    }
}

extension MenuVC: CategoriesVCDelegate{
    func scrollTableToRow(at indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}
