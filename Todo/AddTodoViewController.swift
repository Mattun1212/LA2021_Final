//
//  AddTodoViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/16.
//

import UIKit
import Firebase
import FirebaseFirestore

class AddTodoViewController: UITableViewController{
    let currentUser = Auth.auth().currentUser
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTagSegment: UISegmentedControl!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var datePicker: UIDatePicker = UIDatePicker()
    let alert: Alert = Alert()
    let db = Firestore.firestore()
    var category:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "HarenosoraMincho", size: 22)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        detailTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        detailTextView.layer.borderWidth = 1.0
        detailTextView.layer.cornerRadius = 1.0
        detailTextView.layer.masksToBounds = true
        
        saveButton.isEnabled = false
        
        titleTextField.delegate = self
        detailTextView.delegate = self
        dateTextField.delegate = self
        category = "本"
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(changeDate), for: .valueChanged)
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
        if datePicker.date >= Date(){
            dateTextField.text = "\(formatter.string(from: datePicker.date))"
        }
    }

    
    @objc func doneDate() {
        dateTextField.endEditing(true)
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if datePicker.date >= Date(){
            dateTextField.text = "\(formatter.string(from: datePicker.date))"
        }
        textFieldDidChangeSelection(dateTextField)
        
    }
    
    @IBAction func back(_ sender:Any ){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func categorySegmentControl(_ sender: UISegmentedControl) {
        category = sender.titleForSegment(at: sender.selectedSegmentIndex)!
    }
    
    @IBAction func save(_ sender: Any) {
        if let titleText = titleTextField.text,
           let detailText = detailTextView.text,
           let categoryTag = category,
           let dateText = dateTextField.text {
            db.collection("users").document(currentUser!.uid).collection("todos").document().setData(["title": titleText, "tag": categoryTag, "detail": detailText, "timelimit": dateText], merge: true)
        
        self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension AddTodoViewController: UITextFieldDelegate {
    
    // textFieldでテキスト選択が変更された時に呼ばれるメソッド
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // textFieldが空かどうかの判別するための変数(Bool型)で定義
        let titleIsEmpty = titleTextField.text?.isEmpty ?? true
        let detailIsEmpty = detailTextView.text?.isEmpty ?? true
        let dateIsEmpty = dateTextField.text?.isEmpty ?? true
        // 全てのtextFieldが記入済みの場合の処理
        if titleIsEmpty || detailIsEmpty || dateIsEmpty {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }

    // textField以外の部分を押したときキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension AddTodoViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        // textFieldが空かどうかの判別するための変数(Bool型)で定義
        let titleIsEmpty = titleTextField.text?.isEmpty ?? true
        let detailIsEmpty = detailTextView.text?.isEmpty ?? true
        let dateIsEmpty = dateTextField.text?.isEmpty ?? true
        let validateDate = dateTextField.text?.isDate() ?? true
        // 全てのtextFieldが記入済みの場合の処理
        if titleIsEmpty || detailIsEmpty || dateIsEmpty || (validateDate == false) {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
   
}

extension String {
    func isDate() -> Bool {
        let pattern = "^[0-9]{4}\\-(0[1-9]|1[0-2])\\-(0[1-9]|[12][0-9]|3[01])$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let matches = regex.matches(in: self, range: NSRange(0..<self.count))
        return matches.count > 0
    }
}

