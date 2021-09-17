//
//  ShowTodoViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/16.
//

import UIKit
import Firebase
import FirebaseFirestore

class ShowTodoViewController: UIViewController, UITableViewDelegate {
    let db = Firestore.firestore()
    
    let currentUser = Auth.auth().currentUser
    
    var dataArray: [DataObject]!
    
    var listener: ListenerRegistration?

    var Id: DocumentReference?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        listener = db.collection("users").document(currentUser!.uid).collection("todos").addSnapshotListener { [self] documentSnapshot, error in
                       if let error = error {
                           print("ドキュメントの取得に失敗しました", error)
                       } else {
                           self.dataArray = []
                           if let documentSnapshots = documentSnapshot?.documents {
                               for document in documentSnapshots {
                                let TodoData = DataObject(document: document)
                                self.dataArray.append(TodoData)
                                 DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                 }
                               }
                           }
                       }
                   }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            listener?.remove()
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

}

extension ShowTodoViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return self.dataArray.count
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell")
        let label1 = cell?.contentView.viewWithTag(1) as! UILabel
        let label2 = cell?.contentView.viewWithTag(2) as! UILabel
//        label1.text = self.dataArray[indexPath.row].title
//        label2.text = self.dataArray[indexPath.row].timelimit
        label1.text = "title"
        label2.text = "timelimit"
        return cell!
    }
}

