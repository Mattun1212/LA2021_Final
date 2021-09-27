//
//  EditDoneViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/20.
//

import UIKit
import Firebase
import FirebaseAuth

class EditDoneViewController: UITableViewController {
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    var Data: DoneObject!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var finishDateLabel: UILabel!
    @IBOutlet weak var feelingTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "HarenosoraMincho", size: 22)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        
        titleLabel.text = Data?.title
        tagLabel.text = Data?.tag
        finishDateLabel.text = Data?.date
        feelingTextView.text = Data?.feeling
        feelingTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        feelingTextView.layer.borderWidth = 1.0
        feelingTextView.layer.cornerRadius = 1.0
        feelingTextView.layer.masksToBounds = true
    }
    
    @IBAction func back(_ sender:Any){
        if feelingTextView.text?.count != 0 {
            db.collection("users").document(currentUser!.uid).collection("dones").document(Data.id!).updateData([ "feeling":feelingTextView.text!]) { err in
                if let err = err { // エラーハンドリング
                    print("Error updating document: \(err)")
                } else { // 書き換え成功ハンドリング
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }else{
            let dialog = UIAlertController(title: "エラー", message: "感想を入力してください", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(dialog, animated: true, completion: nil)
        }
    }

}

extension EditDoneViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
