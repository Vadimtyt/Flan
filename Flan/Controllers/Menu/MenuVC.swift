//
//  MenuVC.swift
//  Flan
//
//  Created by Вадим on 01.04.2021.
//

import UIKit

private let reuseIdentifier = "MenuCell"

class MenuVC: UITableViewController {
    
//    let names: Set = ["Пирожок", "Слойка", "Пицца", "Торт", "Коктейль", "Киш", "Кекс"]
    
    var categories: [(category: String, items: [MenuItem])] { get { return ListOfMenuItems.shared.categories }}
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
    var isKeyboardPresented = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: MenuCell.reuseId)
        //ListOfMenuItems.shared.items = generateItems(count: Int.random(in: 30...50))
        
        configureSearchController()
        configureNavigationBarLargeStyle()
        tableView.showsVerticalScrollIndicator = false
        self.definesPresentationContext = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
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
    
//    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//            if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
//                changeTabBar(hidden: true, animated: true)
//            }else{
//                changeTabBar(hidden: false, animated: true)
//            }
//
//        }
//
//    func changeTabBar(hidden:Bool, animated: Bool){
//        guard let tabBar = self.tabBarController?.tabBar else { return; }
//        if tabBar.isHidden == hidden{ return }
//        let frame = tabBar.frame
//        let offset = hidden ? frame.size.height : -frame.size.height
//        let duration:TimeInterval = (animated ? 0.3 : 0.0)
//        tabBar.isHidden = false
//
//        UIView.animate(withDuration: duration, animations: {
//            tabBar.frame = frame.offsetBy(dx: 0, dy: offset)
//        }, completion: { (true) in
//            tabBar.isHidden = hidden
//        })
//    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        }
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isFiltering {
            return 0
        }
        return 40
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MenuCell
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
    
//    func generateItem() -> MenuItem {
//        return MenuItem(name: names.randomElement() ?? "Error", price: Int.random(in: 100...500))
//    }
//
//    func generateItems(count: Int) -> [MenuItem] {
//        var items: [MenuItem] = []
//
//        for _ in 0...count {
//            let newItem = generateItem()
//            items.append(newItem)
//        }
//
//        return items
//    }
    
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
