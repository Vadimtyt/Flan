//
//  InfoPopover.swift
//  Flan
//
//  Created by Вадим on 24.05.2021.
//

import UIKit
    
class InfoPopover: UIViewController {
    private let text: String
    private let fontSize: CGFloat
    private let topConstraint: CGFloat
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var constraintTop: NSLayoutConstraint!
    
    override func viewDidLoad() {
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: fontSize)
        constraintTop.constant = topConstraint
    }
    
    init(text: String?, fontSize: CGFloat?, topConstraint: CGFloat?) {
        self.text = text ?? ""
        self.fontSize = fontSize ?? 18
        self.topConstraint = topConstraint ?? 8

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
