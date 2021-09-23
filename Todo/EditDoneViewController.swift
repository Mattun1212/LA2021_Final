//
//  EditDoneViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/20.
//

import UIKit
import Firebase
import FirebaseAuth

class EditDoneViewController: UIViewController {
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    var Data: DoneObject!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var feelingTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = Data?.title
        tagLabel.text = Data?.tag
        feelingTextView.text = Data?.feeling
        feelingTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        feelingTextView.layer.borderWidth = 1.0
        feelingTextView.layer.cornerRadius = 1.0
        feelingTextView.layer.masksToBounds = true
        
      //  feelingTextView.delegate = self

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



//extension EditDoneViewController: UINavigationControllerDelegate{
//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//           if viewController is ShowDoneViewController{
//            if let feelingText = feelingTextView.text{
//                db.collection("users").document(currentUser!.uid).collection("dones").document(Data.id!).updateData(["feeling": feelingText]) { err in
//                    if let err = err { // エラーハンドリング
//                        print("Error updating document: \(err)")
//                    } else { // 書き換え成功ハンドリング
//                        print("aaaaaaaaaa")
//                    }
//
//                }
//            }
//       }
//    }
//}

//extension EditDoneViewController: UITextViewDelegate {
//
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        // textFieldが空かどうかの判別するための変数(Bool型)で定義
//        let feelingIsEmpty = feelingTextView.text?.isEmpty ?? true
//        // 全てのtextFieldが記入済みの場合の処理
//        if feelingIsEmpty  {
//            doneButton.isEnabled = false
//        } else {
//            doneButton.isEnabled = true
//        }
//    }
//
//}
