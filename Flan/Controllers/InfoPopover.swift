//
//  InfoPopover.swift
//  Flan
//
//  Created by Вадим on 24.05.2021.
//

import UIKit
    
class InfoPopover: UIViewController {
    
    // MARK: - Props
    
    private let text: String
    private let fontSize: CGFloat
    
    // MARK: - @IBOutet
    
    @IBOutlet private weak var textLabel: UILabel!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: fontSize)
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.5
    }
    
    init(text: String?, fontSize: CGFloat?) {
        self.text = text ?? ""
        self.fontSize = fontSize ?? 18
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
