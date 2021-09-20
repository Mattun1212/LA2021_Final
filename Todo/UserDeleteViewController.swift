//
//  UserDeleteViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/19.
//

import UIKit
import Firebase
import FirebaseFirestore

class UserDeleteViewController: UIViewController {
    
    let alert: Alert = Alert()
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    var credential: AuthCredential!
    var email:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        
        db.collection("users").document(currentUser!.uid).getDocument { (snap, error) in
            if let error = error {
                fatalError("\(error)")
            }
            let data = snap?.data()
            self.email = data?["email"] as? String
        }
    }
    

    @IBAction func userDelete(_ sender: Any){
        credential = EmailAuthProvider.credential(withEmail: email ?? "", password: passwordTextField.text ?? "")
        if currentUser != nil {
            currentUser?.reauthenticate(with: credential!, completion: { [self] dataResult,error in
              if let error = error {
                let dialog = UIAlertController(title: "認証失敗", message: error.localizedDescription, preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(dialog, animated: true, completion: nil)
              } else {
                currentUser?.delete { error in
                    if let error = error {
                        let dialog = UIAlertController(title: "ユーザ削除失敗", message: error.localizedDescription, preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        present(dialog, animated: true, completion: nil)
                    } else {
                        self.db.collection("users").document(currentUser!.uid).delete() { error in
                           if let error = error {
                            let dialog = UIAlertController(title: "ユーザ情報は削除されましたが、データが削除されませんでした", message: error.localizedDescription, preferredStyle: .alert)
                            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            present(dialog, animated: true, completion: nil)
                           } else {
                            let dialog = UIAlertController(title: "ユーザ情報が削除されました", message: nil, preferredStyle: .alert)
                            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            present(dialog, animated: true, completion: nil)
                            self.performSegue(withIdentifier: "Signout", sender: nil)
                           }
                        }
                    }
                }
              }
            })
        }
    }

}

extension UserDeleteViewController: UITextFieldDelegate {
    // textFieldでテキスト選択が変更された時に呼ばれるメソッド
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // textFieldが空かどうかの判別するための変数(Bool型)で定義
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        // 全てのtextFieldが記入済みの場合の処理
        if passwordIsEmpty {
            submitButton.isEnabled = false
          
        } else {
            submitButton.isEnabled = true

        }
    }

    // textField以外の部分を押したときキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
