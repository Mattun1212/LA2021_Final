//
//  TabbarViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/28.
//

import UIKit

class TabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UITabBarItem.appearance().setTitleTextAttributes([.font : UIFont(name: "HarenosoraMincho", size: 11)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.font : UIFont(name: "HarenosoraMincho", size: 11)!], for: .selected)
        
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        guard let tabContent = viewController as? UINavigationController else {
            return true
        }
        let navigationContent = tabContent.viewControllers[0]
        if nil != navigationContent as? ShowTodoViewController {
            UITabBarItemAppearance().selected.iconColor = UIColor(hex: "F84124")
            UITabBarItemAppearance().selected.titleTextAttributes = [.foregroundColor: UIColor(hex: "F84124")]
        
        } else if nil != navigationContent as? ShowDoneViewController  {
            UITabBarItemAppearance().selected.iconColor = UIColor(hex: "C0E2A1")
            UITabBarItemAppearance().selected.titleTextAttributes = [.foregroundColor: UIColor(hex: "C0E2A1")]
            
        }else {
            UITabBarItemAppearance().selected.iconColor = UIColor(hex: "6D7CD1")
            UITabBarItemAppearance().selected.titleTextAttributes = [.foregroundColor: UIColor(hex: "6D7CD1")]
            
        }
        return true
    }

}
