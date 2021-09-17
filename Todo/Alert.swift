//
//  Alert.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/16.
//

import UIKit

public class Alert {
    
    func fail(titleText: String, actionTitleText: String, message: String) -> UIAlertController {
        let dialog = UIAlertController(title: titleText, message: message, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: actionTitleText, style: .default, handler: nil))
        return dialog
    }

}
