//
//  MemeTextFieldDelegate.swift
//  MemeMeV1
//
//  Created by Ansuke on 12/12/17.
//  Copyright © 2017 AM. All rights reserved.
//

import Foundation
import UIKit

class MemeTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    var activeField = UITextField()
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP " || textField.text == "BOTTOM " {
            textField.text = ""
        }
        
        activeField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            if textField.tag == 0 {
                textField.text = "TOP "
            } else if textField.tag == 1 {
                textField.text = "BOTTOM "
            }
        }
        activeField = textField
    }
}
