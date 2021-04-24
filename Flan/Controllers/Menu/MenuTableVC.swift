//
//  MenuTableVC.swift
//  Flan
//
//  Created by Вадим on 01.04.2021.
//

import UIKit

private let reuseIdentifier = "MenuTableCell"

class MenuTableVC: UITableViewController {
    
    let names: Set = ["Пирожок", "Слойка", "Пицца", "Торт", "Коктейль", "Киш", "Кекс"]

    var items: [MenuItem] = ListOfMenuItems.shared.list
    
    weak var delegate: UITabBarControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MenuTableCell", bundle: nil), forCellReuseIdentifier: MenuTableCell.reuseId)
        
        //self.navigationController?.tabBarController?.tabBar.items?[2].badgeValue = "11"
        
        print(self.navigationController?.tabBarController?.tabBar.items?[1].title)
        print(self.navigationController?.tabBarController?.tabBar.items?[2].title)
        
        items = generateList(count: Int.random(in: 5...20))
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MenuTableCell
        let item = items[indexPath.row]
        
        cell.configureCell(with: item)
        cell.viewController = self
 
        return cell
    }
    
    func generateItem() -> MenuItem {
        return MenuItem(name: names.randomElement() ?? "Error", price: Int.random(in: 100...500))
    }
    
    func generateList(count: Int) -> [MenuItem]{
        var list: [MenuItem] = []
        
        for _ in 0...count {
            let newItem = generateItem()
            list.append(newItem)
        }
        
        return list
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
