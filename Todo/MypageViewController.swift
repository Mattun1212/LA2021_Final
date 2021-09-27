//
//  MypageViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/19.
//

import UIKit
import Firebase
import FirebaseFirestore

class MypageViewController: UIViewController {

    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    var credential: AuthCredential!
    var listener: ListenerRegistration?
    var Data: userInfo!
    var email:String?
    var password:String?
    
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var rankLabel:UILabel!
    @IBOutlet weak var rankProgressbar:UIProgressView!
    @IBOutlet weak var leftSuccessLabel:UILabel!
    @IBOutlet weak var darumaImageView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "HarenosoraMincho", size: 22)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        UITabBarItemAppearance().selected.iconColor = UIColor(hex: "6D7CD1")
        UITabBarItemAppearance().selected.titleTextAttributes = [.foregroundColor: UIColor(hex: "6D7CD1")]
    
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
            nameLabel.text = data["userName"] as? String
            let success = data["successTimes"] as? Int ?? 0
            let daruma = data["currentDaruma"] as? Int ?? 0
            email = data["email"] as? String
            rankLabel.text = "\(calculateRank(success: success))"
            let progress = Float(success % 4) / 4
            rankProgressbar.setProgress(progress, animated: true)
            view.addSubview(rankProgressbar)
            leftSuccessLabel.text = "あと\(4 - success % 4)回"
            setImage(daruma: daruma)
        }
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            listener?.remove()
    }
    
    func setImage(daruma: Int){
        if daruma == 0 {
            darumaImageView.image = UIImage(named: "left4")
        }else if daruma == 1{
            darumaImageView.image = UIImage(named: "left3")
        }else if daruma == 2{
            darumaImageView.image = UIImage(named: "left2")
        }else if daruma == 3{
            darumaImageView.image = UIImage(named: "left1")
        }
    }

     func logout() {
        if currentUser != nil {
            let dialog = UIAlertController(title: "ログアウト", message: "本当にログアウトしますか？", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                do {
                    try Auth.auth().signOut()
                    self.dismiss(animated: true, completion: nil)
                    self.performSegue(withIdentifier: "Logout", sender: nil)
                } catch let error as NSError {
                    let dialog = UIAlertController(title: "ログアウト失敗", message: error.localizedDescription, preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }
            }))
            dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            
            present(dialog, animated: true, completion: nil)
        }
    }
    
    func userDelete() {
        let dialog = UIAlertController(title: "ユーザ認証", message: "パスワードを入力", preferredStyle: .alert)
        dialog.addTextField(configurationHandler: {(textField) -> Void in
            textField.delegate = self
            textField.isSecureTextEntry = true
        })
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action) in
        credential = EmailAuthProvider.credential(withEmail: email ?? "", password: password ?? "")
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
                            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                              self.dismiss(animated: true, completion: nil)
                              self.performSegue(withIdentifier: "Logout", sender: nil)
                            }))
                            present(dialog, animated: true, completion: nil)
                           }
                        }
                    }
                }
              }
            })
        }
        }))
        
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(dialog, animated: true, completion: nil)
    }
    
    func calculateRank(success: Int) -> Int{
        let base = 1 + Int(success / 4)
        return base
    }
    
    @IBAction func handleAction(_ sender: Any){
         let actionSheet = UIAlertController(title: "Menu", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
     
         let action1 = UIAlertAction(title: "ログアウトする", style: UIAlertAction.Style.destructive, handler: {
             (action: UIAlertAction!) in
             self.logout()
         })
        
         let action2 = UIAlertAction(title: "ユーザ情報を削除する", style: UIAlertAction.Style.destructive, handler: {
             (action: UIAlertAction!) in
            self.userDelete()
         })

         actionSheet.addAction(action1)
         actionSheet.addAction(action2)
         actionSheet.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))

         self.present(actionSheet, animated: true, completion: nil)
         
     }

}

extension MypageViewController: UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        password = textField.text
    }
}
