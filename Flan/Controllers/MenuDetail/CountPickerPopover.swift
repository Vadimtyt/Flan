//
//  CountPickerPopover.swift
//  Flan
//
//  Created by Вадим on 14.06.2021.
//

import UIKit

// MARK: - Protocol

protocol UpdatingCountPickerPopoverDelegate: AnyObject {
    func updateCell(with itemCount: Int)
}
    
class CountPickerPopover: UIViewController {
    
    // MARK: - Protocol
    
    private let currentCount: Int
    private let pickerData = Array(0...99)
    
    weak var updatingMenuDetailVCDelegate: UpdatingCountPickerPopoverDelegate!
    
    // MARK: - @IBOutlets
    
    @IBOutlet weak var countPicker: UIPickerView!
    
    // MARK: - Initialiszation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countPicker.delegate = self
        countPicker.dataSource = self
        countPicker.selectRow(currentCount, inComponent: 0, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateItemCount()
    }
    
    init(currentCount: Int, updatingDelegate: UpdatingCountPickerPopoverDelegate) {
        self.currentCount = currentCount
        self.updatingMenuDetailVCDelegate = updatingDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Funcs
    
    private func updateItemCount() {
        let itemCount = countPicker.selectedRow(inComponent: 0)
        updatingMenuDetailVCDelegate.updateCell(with: itemCount)
    }
    
    // MARK: - @IBActions
    
    @IBAction private func doneButtonPressed(_ sender: UIButton) {
        updateItemCount()
        dismiss(animated: true)
    }
}

// MARK: - UIPickerView data sourse

extension CountPickerPopover: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        String(pickerData[row])
    }
}
