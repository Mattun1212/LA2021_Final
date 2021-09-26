//
//  DoneTodoViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/20.
//

import UIKit
import Firebase
import FirebaseAuth

class DoneTodoViewController: UIViewController {

    var Data: DataObject!
    var userData: userInfo!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var finishDateLabel: UILabel!
    @IBOutlet weak var feelingTextView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    
    var listener: ListenerRegistration?
    let currentUser = Auth.auth().currentUser
    let alert: Alert = Alert()
    let db = Firestore.firestore()
    var successTimes: Int!
    var currentDaruma: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = Data?.title
        tagLabel.text = Data?.tag
        finishDateLabel.text = Data?.timelimit
        feelingTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        feelingTextView.layer.borderWidth = 1.0
        feelingTextView.layer.cornerRadius = 1.0
        feelingTextView.layer.masksToBounds = true
        feelingTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        listener = db.collection("users").document(currentUser!.uid).addSnapshotListener { [self] documentSnapshot, error in
            guard let document = documentSnapshot else {
              print("Error fetching document: \(error!)")
              return
            }
            guard let data = document.data() else {
              print("Document data was empty.")
              return
            }
            
           if let success = data["successTimes"] as? Int,
              let daruma = data["currentDaruma"] as? Int{
                successTimes  = success
                currentDaruma = daruma
           }
            
                               
        }
    
    }
    
    @IBAction func done(_ sender:Any){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: Date())
        
        if let title = titleLabel.text,
           let tag = tagLabel.text,
           let feelingText = feelingTextView.text{
            
            db.collection("users").document(currentUser!.uid).collection("dones").document(Data.id!).setData(["title": title, "tag": tag, "feeling": feelingText, "date": date]) { [self] err in
                    if let err = err { // エラーハンドリング
                        let dialog = UIAlertController(title: "doneデータ登録失敗", message: err.localizedDescription, preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        present(dialog, animated: true, completion: nil)
                    } else { // 書き換え成功ハンドリング
                        db.collection("users").document(currentUser!.uid).collection("todos").document(Data.id!).delete(){ err in
                            if let err = err { // エラーハンドリング
                                let dialog = UIAlertController(title: "todoデータ削除失敗", message: err.localizedDescription, preferredStyle: .alert)
                                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                present(dialog, animated: true, completion: nil)
                            } else {
                                setDaruma()
                                db.collection("users").document(currentUser!.uid).updateData(["successTimes": successTimes!,"currentDaruma": currentDaruma!]){ err in
                                    if let err = err { // エラーハンドリング
                                        let dialog = UIAlertController(title: "ランク更新失敗", message: err.localizedDescription, preferredStyle: .alert)
                                        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        present(dialog, animated: true, completion: nil)
                                    } else { // 書き換え成功ハンドリング
                                        print("Update successfully!")
                                    }
                                }
                            }
                        }
                    }
            let index = navigationController!.viewControllers.count - 3
            self.navigationController?.popToViewController(navigationController!.viewControllers[index], animated: true)
           }
        }
    
    }
    
    func setDaruma(){
        if currentDaruma == 3{
            currentDaruma = 0
            successTimes += 1
        }else{
            currentDaruma += 1
        }
    }
    
}

extension DoneTodoViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        // textFieldが空かどうかの判別するための変数(Bool型)で定義
        let feelingIsEmpty = feelingTextView.text?.isEmpty ?? true
        // 全てのtextFieldが記入済みの場合の処理
        if feelingIsEmpty  {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }

}

