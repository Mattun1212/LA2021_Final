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
    
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var lankLabel:UILabel!
//    @IBOutlet weak var darumaLabel:UILabel!
    @IBOutlet weak var darumaImageView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            lankLabel.text = "\(calculateRank(success: success))"
//            darumaLabel.text = "\(String(daruma))/4"
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

    @IBAction func logout(_ sender: Any) {
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
    
    func calculateRank(success: Int) -> Int{
        let base = 1 + Int(success / 4)
        return base
    }

}
