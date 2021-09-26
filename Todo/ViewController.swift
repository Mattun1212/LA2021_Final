//
//  ViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }
    
}
