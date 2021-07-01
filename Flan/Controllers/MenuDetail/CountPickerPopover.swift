//
//  CountPickerPopover.swift
//  Flan
//
//  Created by Вадим on 14.06.2021.
//

import UIKit

protocol UpdatingMenuDetailVCDelegate: AnyObject {
    func updateCell(with itemCount: Int)
}
    
class CountPickerPopover: UIViewController {
    
    private let currentCount: Int
    let pickerData = Array(0...99)
    
    weak var updatingMenuDetailVCDelegate: UpdatingMenuDetailVCDelegate!
    
    @IBOutlet weak var countPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countPicker.delegate = self
        countPicker.dataSource = self
        
        countPicker.selectRow(currentCount, inComponent: 0, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateItemCount()
    }
    
    init(currentCount: Int, updatingDelegate: UpdatingMenuDetailVCDelegate) {
        self.currentCount = currentCount
        self.updatingMenuDetailVCDelegate = updatingDelegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateItemCount() {
        let itemCount = countPicker.selectedRow(inComponent: 0)
        updatingMenuDetailVCDelegate.updateCell(with: itemCount)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        updateItemCount()
        dismiss(animated: true)
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
        return String(pickerData[row])
    }
}