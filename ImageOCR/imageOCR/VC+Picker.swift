//
//  VC+Picker.swift
//  imageOCR
//
//  Created by 杨光 on 2020/12/6.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import UIKit
import SceneKit
import ARKit



extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bookAttr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) ->String? {
        return bookAttr[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nowSelection = row
        // The parameter named row and component represents what was selected.
    }

}
