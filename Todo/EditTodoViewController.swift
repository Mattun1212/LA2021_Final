//
//  EditTodoViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/16.
//

import UIKit
import Firebase
import FirebaseAuth

class EditTodoViewController: UIViewController {
    let currentUser = Auth.auth().currentUser
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTagSegment: UISegmentedControl!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
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
        dateTextField.delegate = self

        
        navigationController?.delegate = self
        if Data?.tag == "ゲーム" {
            categoryTagSegment.selectedSegmentIndex = 1
        }else if Data?.tag == "その他"{
            categoryTagSegment.selectedSegmentIndex = 2
        }
        
        titleTextField.text = Data?.title
        category = Data?.tag
        detailTextView.text = Data?.detail
        dateTextField.text = Data?.timelimit

        
        doneButton.isEnabled = true
        
        
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(changeDate), for: .valueChanged)
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy/MM/dd"
        let date = Data?.timelimit
        datePicker.date = formatter.date(from: date!)!
        
        dateTextField.inputView = datePicker
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneDate))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = toolbar
    }
    

    @objc func changeDate(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = "\(formatter.string(from: datePicker.date))"
    }
    
    @objc func doneDate() {
        dateTextField.endEditing(true)
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = "\(formatter.string(from: datePicker.date))"
        textFieldDidChangeSelection(dateTextField)
    }
    
    @IBAction func categorySegmentControl(_ sender: UISegmentedControl) {
        category = sender.titleForSegment(at: sender.selectedSegmentIndex)!
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDone" {
            let Done = segue.destination as! DoneTodoViewController
                Done.Data = Data
        }
    }
    
    @IBAction func deleteTodo(_ sender:Any){
        let dialog = UIAlertController(title: "削除", message: "削除すると現在のだるま落としがやり直しになりますが本当に削除しますか？", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action) in
            self.db.collection("users").document(currentUser!.uid).collection("todos").document(Data.id!).delete() { err in
                    if let err = err {
                        let dialog = UIAlertController(title: "削除失敗", message: err.localizedDescription, preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    } else {
                        self.db.collection("users").document(currentUser!.uid).updateData(["currentDaruma": 0]){ err in
                                if let err = err { // エラーハンドリング
                                    print("Error updating document: \(err)")
                                } else { // 書き換え成功ハンドリング
                                    print("Update successfully!")
                                }
                        }
                    }
                    
                }
                self.navigationController?.popViewController(animated: true)
        
        }))
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        present(dialog, animated: true, completion: nil)
    }
    
}

extension EditTodoViewController: UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
           if viewController is ShowTodoViewController{
            if let titleText = titleTextField.text,
               let detailText = detailTextView.text,
               let categoryTag = category,
               let dateText = dateTextField.text {
                db.collection("users").document(currentUser!.uid).collection("todos").document(Data.id!).updateData(["title": titleText, "tag": categoryTag, "detail": detailText, "timelimit": dateText]) { err in
                    if let err = err { // エラーハンドリング
                        print("Error updating document: \(err)")
                    } else { // 書き換え成功ハンドリング
                        print("Update successfully!")
                    }
                    
                }
           }
       }
    }
}

extension EditTodoViewController: UITextFieldDelegate {
    
    // textFieldでテキスト選択が変更された時に呼ばれるメソッド
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // textFieldが空かどうかの判別するための変数(Bool型)で定義
        let titleIsEmpty = titleTextField.text?.isEmpty ?? true
        let detailIsEmpty = detailTextView.text?.isEmpty ?? true
        let dateIsEmpty = dateTextField.text?.isEmpty ?? true

        // 全てのtextFieldが記入済みの場合の処理
        if titleIsEmpty || detailIsEmpty || dateIsEmpty{
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }

    // textField以外の部分を押したときキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension EditTodoViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        // textFieldが空かどうかの判別するための変数(Bool型)で定義
        let titleIsEmpty = titleTextField.text?.isEmpty ?? true
        let detailIsEmpty = detailTextView.text?.isEmpty ?? true
        let dateIsEmpty = dateTextField.text?.isEmpty ?? true
        // 全てのtextFieldが記入済みの場合の処理
        if titleIsEmpty || detailIsEmpty || dateIsEmpty {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }

}
