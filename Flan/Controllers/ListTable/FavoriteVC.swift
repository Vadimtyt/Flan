//
//  FavoriteVC.swift
//  Flan
//
//  Created by Вадим on 20.02.2021.
//

import UIKit

private let reuseIdentifier = "MenuCell"

class FavoriteVC: UITableViewController, FavoriteVCDelegate {

    private let indexOfListVC = 2
    
    var items: [MenuItem] = ListOfMenuItems.shared.favorites

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: MenuCell.reuseId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateFavoriteVC()
    }
    
    func updateListBadge() {
        let items = ListOfMenuItems.shared.items
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
