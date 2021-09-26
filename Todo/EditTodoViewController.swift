//
//  EditTodoViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/16.
//

import UIKit
import Firebase
import FirebaseAuth

class EditTodoViewController: UITableViewController,UITextViewDelegate{
    let currentUser = Auth.auth().currentUser
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTagSegment: UISegmentedControl!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var Data: DataObject!
    var category: String?
    var datePicker: UIDatePicker = UIDatePicker()
    let alert: Alert = Alert()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        detailTextView.layer.borderWidth = 1.0
        detailTextView.layer.cornerRadius = 1.0
        detailTextView.layer.masksToBounds = true
        
        titleTextField.delegate = self
        detailTextView.delegate = self
        
        if Data?.tag == "ゲーム" {
            categoryTagSegment.selectedSegmentIndex = 1
        }else if Data?.tag == "その他"{
            categoryTagSegment.selectedSegmentIndex = 2
        }
        
        titleTextField.text = Data?.title
        category = Data?.tag
        detailTextView.text = Data?.detail
        dateLabel.text = Data?.timelimit
    
    }
    

    
    
    @IBAction func categorySegmentControl(_ sender: UISegmentedControl) {
        category = sender.titleForSegment(at: sender.selectedSegmentIndex)!
    }
    
    @IBAction func back(_ sender:Any){
        if titleTextField.text?.count != 0 , detailTextView.text?.count != 0 {
            db.collection("users").document(currentUser!.uid).collection("todos").document(Data.id!).updateData(["title": titleTextField.text!, "tag": category!, "detail": detailTextView.text!]) { err in
                if let err = err { // エラーハンドリング
                    print("Error updating document: \(err)")
                } else { // 書き換え成功ハンドリング
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }else{
            let dialog = UIAlertController(title: "エラー", message: "タイトルと詳細を入力してください", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(dialog, animated: true, completion: nil)
        }
    }
}

extension EditTodoViewController: UITextFieldDelegate {
    
    // textField以外の部分を押したときキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

