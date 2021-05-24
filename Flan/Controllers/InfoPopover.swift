//
//  InfoPopover.swift
//  Flan
//
//  Created by Вадим on 24.05.2021.
//

import UIKit
    
class InfoPopover: UIViewController {
    var text = ""
    var fontSize: CGFloat = 18
    var topConstraint: CGFloat = 8
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    
    override func viewDidLoad() {
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: fontSize)
        constraintTop.constant = topConstraint
    }
}
