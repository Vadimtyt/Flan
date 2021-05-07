//
//  MoreVC.swift
//  Flan
//
//  Created by Вадим on 07.05.2021.
//

import UIKit

private let reuseIdentifier = "BakeryCell"

private let bakeries = [
    Bakery(name: "Флан на Новой", address: "ул.Новая, 14А", phone: "+7(989)248-14-14", openTime: 8, closeTime: 21),
    Bakery(name: "Флан на Отдельской", address: "ул.Отдельская 324/7", phone: "+7(988)135-07-07", openTime: 9, closeTime: 22),
    Bakery(name: "Флан на Школьной", address: "уд.Школьная, 301А", phone: "+7(918)123-45-67", openTime: 8, closeTime: 20),
    Bakery(name: "Флан на Лермонтова", address: "ул.Лермонтова, 216Г", phone: "+7(988)316-21-21", openTime: 8, closeTime: 21)
]

class MoreVC: UIViewController, BakeryCellDelegate {
    
    //var bakeries: [Bakery] = []
    let countOfbakeries = 4
    
    @IBOutlet weak var bakeriesTableView: UITableView!
    
    override func viewDidLoad() {
        bakeriesTableView.delegate = self
        bakeriesTableView.dataSource = self
        bakeriesTableView.isScrollEnabled = false
        
        bakeriesTableView.register(UINib(nibName: "BakeryCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }
    
    func openMap(with tag: Int) {
        //
    }
    
    func callPhone(with tag: Int) {
        //
    }
}

extension MoreVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countOfbakeries
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BakeryCell
 
        let bakery = bakeries[indexPath.row]
        cell.configureCell(with: bakery, and: indexPath.row)
        cell.bakeryCellDelegate = self
        cell.selectionStyle = .none
 
        return cell
    }
    
    
}
