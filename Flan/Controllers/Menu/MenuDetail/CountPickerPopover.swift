//
//  CountPickerPopover.swift
//  Flan
//
//  Created by Вадим on 14.06.2021.
//

import UIKit
    
class CountPickerPopover: UIViewController {
    
    private let currentCount: Int
    let pickerData = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"]
    @IBOutlet weak var countPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countPicker.delegate = self
        countPicker.dataSource = self
    }
    
    init(currentCount: Int) {
        self.currentCount = currentCount
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CountPickerPopover: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return pickerData[row]
    }
}
