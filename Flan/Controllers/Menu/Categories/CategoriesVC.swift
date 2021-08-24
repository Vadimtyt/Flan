//
//  CategoriesVC.swift
//  Flan
//
//  Created by Вадим on 27.05.2021.
//

import UIKit

protocol CategoriesVCDelegate: AnyObject {
    func scrollTableToRow(at indexPath: IndexPath)
}

class CategoriesVC: UIViewController {

    weak var categoriesVCDelegate: CategoriesVCDelegate?
    var categories: [(category: String, items: [MenuItem])] { DataManager.shared.getCategories() }
    
    private var hasSetPointOrigin = false
    private var pointOrigin: CGPoint?
    private var isScrollViewAtTopPosition = true
    private var isScrollBeganFromTop = true
    private var isScrollingViewWithTable = false
    
    @IBOutlet private weak var slideIdicator: UIView!
    @IBOutlet private weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        slideIdicator.roundCorners(.allCorners, radius: 10)
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            pointOrigin = self.view.frame.origin
            hasSetPointOrigin = true
        }
    }
    
    @objc private func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 || translation.y > 200 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                backToPointOrigin()
            }
        }
    }
    
    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !isScrollBeganFromTop && scrollView.contentOffset.y < 0 {
            backToPointOrigin()
        }

        if scrollView.contentOffset.y < 0 || self.view.frame.origin.y > self.pointOrigin?.y ?? CGPoint(x: 0, y: 400).y {
            self.view.frame = CGRect(x: 0,
                                     y: self.view.frame.minY - scrollView.contentOffset.y/2,
                                     width: self.view.frame.width,
                                     height: self.view.frame.height)
            scrollView.contentOffset.y = 0
            
            isScrollingViewWithTable = true
        }
        
        
        if scrollView.contentOffset.y > 0 {
            isScrollViewAtTopPosition = false
        } else if scrollView.contentOffset.y <= 0 {
            isScrollViewAtTopPosition = true
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrollBeganFromTop = isScrollViewAtTopPosition
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let scrollDownDistance = self.view.frame.origin.y - (self.pointOrigin?.y ?? CGPoint(x: 0, y: 400).y)
        
        if isScrollingViewWithTable && scrollDownDistance > 20 && (velocity.y < -1.5 || scrollDownDistance > 100) {
            dismiss(animated: true)
        }
        
        if scrollDownDistance != 0 {
            backToPointOrigin()
        }
        
        isScrollingViewWithTable = false
    }
    
    func backToPointOrigin() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction) {
            self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
        }
    }
    
}

// MARK: - Table view data source

extension CategoriesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = categories[indexPath.row].category

            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = categories[indexPath.row].category
        }
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        dismiss(animated: true)
        let menuIndexPath = IndexPath(row: 0, section: indexPath.row)
        categoriesVCDelegate?.scrollTableToRow(at: menuIndexPath)
    }
}
