//
//  EditTodoViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/16.
//

import UIKit
import Firebase
import FirebaseAuth

class EditTodoViewController: UIViewController,UITextViewDelegate{
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

    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toDone" {
//            let Done = segue.destination as! DoneTodoViewController
//                Done.Data = Data
//        }
//    }
    
//    @IBAction func deleteTodo(_ sender:Any){
//        let dialog = UIAlertController(title: "削除", message: "削除すると現在のだるま落としがやり直しになりますが本当に削除しますか？", preferredStyle: .alert)
//        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action) in
//            self.db.collection("users").document(currentUser!.uid).collection("todos").document(Data.id!).delete() { err in
//                    if let err = err {
//                        let dialog = UIAlertController(title: "削除失敗", message: err.localizedDescription, preferredStyle: .alert)
//                        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                    } else {
//                        self.db.collection("users").document(currentUser!.uid).updateData(["currentDaruma": 0]){ err in
//                                if let err = err { // エラーハンドリング
//                                    print("Error updating document: \(err)")
//                                } else { // 書き換え成功ハンドリング
//                                    print("Update successfully!")
//                                }
//                        }
//                    }
//
//                }
//                self.navigationController?.popViewController(animated: true)
//
//        }))
//        dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
//
//        present(dialog, animated: true, completion: nil)
//    }
    
}

//extension EditTodoViewController: UINavigationControllerDelegate{
//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//           if viewController is ShowTodoViewController{
//            if let titleText = titleTextField.text,
//               let detailText = detailTextView.text,
//               let categoryTag = category {
//                db.collection("users").document(currentUser!.uid).collection("todos").document(Data.id!).updateData(["title": titleText, "tag": categoryTag, "detail": detailText]) { err in
//                    if let err = err { // エラーハンドリング
//                        print("Error updating document: \(err)")
//                    } else { // 書き換え成功ハンドリング
//                        print("Update successfully!")
//                    }
//
//                }
//           }
//       }
//    }
//}

extension EditTodoViewController: UITextFieldDelegate {
    
    // textFieldでテキスト選択が変更された時に呼ばれるメソッド
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//        // textFieldが空かどうかの判別するための変数(Bool型)で定義
//        let titleIsEmpty = titleTextField.text?.isEmpty ?? true
//        let detailIsEmpty = detailTextView.text?.isEmpty ?? true
//
//        // 全てのtextFieldが記入済みの場合の処理
//        if titleIsEmpty || detailIsEmpty{
//            doneButton.isEnabled = false
//        } else {
//            doneButton.isEnabled = true
//        }
//    }

    // textField以外の部分を押したときキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//extension EditTodoViewController: UITextViewDelegate {
//
//    func textViewDidChangeSelection(_ textView: UITextView) {
        // textFieldが空かどうかの判別するための変数(Bool型)で定義
//        let titleIsEmpty = titleTextField.text?.isEmpty ?? true
//        let detailIsEmpty = detailTextView.text?.isEmpty ?? true
        // 全てのtextFieldが記入済みの場合の処理
//        if titleIsEmpty || detailIsEmpty{
//            doneButton.isEnabled = false
//        } else {
//            doneButton.isEnabled = true
//        }
//    }
//
//}
