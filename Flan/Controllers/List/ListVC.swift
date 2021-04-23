//
//  ListVC.swift
//  Flan
//
//  Created by Вадим on 07.04.2021.
//

import UIKit

private let reuseIdentifier = "ListCell"

class ListVC: UIViewController {

    let names: Set = ["Пирожок", "Слойка", "Пицца", "Торт", "Коктейль", "Киш", "Кекс"]
    
    var items: [MenuItem] = []
    
    @IBOutlet weak var listTableView: UITableView!
    
    @IBOutlet weak var totalSumLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.delegate = self
        listTableView.dataSource = self
        
        items = generateList(count: Int.random(in: 5...10))
        changeTotalSumLabel()
        
        listTableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    func generateItem() -> MenuItem {
        let item = MenuItem(name: names.randomElement() ?? "Error", price: Int.random(in: 100...500))
        item.count = 1
        return item
    }
    
    func generateList(count: Int) -> [MenuItem]{
        var list: [MenuItem] = []
        
        for _ in 0...count {
            let newItem = generateItem()
            list.append(newItem)
        }
        
        return list
    }
    
    func changeTotalSumLabel() {
        var newSum = 0
        for item in items {
            newSum += item.price
        }
        
        totalSumLabel.text = "Итого: \(newSum)Р"
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
    }
}

extension ListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ListCell
 
        let item = items[indexPath.row]
        cell.configureCell(with: item)
        
        items.append(item)
        
        if indexPath.row == items.count {
            changeTotalSumLabel()
        }
 
        return cell
    }
    
    
    
}
