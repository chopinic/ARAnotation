//
//  Controller+UIText.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/6.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import UIKit


//extension ViewController: UITextViewDelegate{
//
//}


extension UITextField {
    
//    public class let textPressEnterNotification: NSNotification.Name

    // Adds a UIToolbar with a dismiss button as UITextView's inputAccesssoryView (which appears on top of the keyboard)
    func addDismissButton() {
        let dismissToolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 44)))
        dismissToolbar.barStyle = .default
        let dismissButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        dismissToolbar.items = [dismissButton]
        inputAccessoryView = dismissToolbar
    }
    
    @objc
    func dismissKeyboard() {
        endEditing(true)
    }
    
}
