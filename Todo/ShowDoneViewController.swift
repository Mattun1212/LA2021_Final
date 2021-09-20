//
//  ShowDoneViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/20.
//

import UIKit
import Firebase
import FirebaseFirestore

class ShowDoneViewController: UIViewController {
    let db = Firestore.firestore()
    
    let currentUser = Auth.auth().currentUser
    
    var dataArray: [DoneObject] = []
    
    var listener: ListenerRegistration?

    var Id: DocumentReference?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        listener = db.collection("users").document(currentUser!.uid).collection("dones").addSnapshotListener { [self] documentSnapshot, error in
                       if let error = error {
                           print("ドキュメントの取得に失敗しました", error)
                       } else {
                        self.dataArray = []
                           if let documentSnapshots = documentSnapshot?.documents {
                               for document in documentSnapshots {
                                let TodoData = DoneObject(document: document)
                                self.dataArray.append(TodoData)
                                 DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                 }
                               }
                           }
                       }
           
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.dataArray == [] {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            listener?.remove()
    }

}

extension ShowDoneViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return self.dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoneCell")
        let label1 = cell?.contentView.viewWithTag(1) as! UILabel
        let label2 = cell?.contentView.viewWithTag(2) as! UILabel
        let label3 = cell?.contentView.viewWithTag(3) as! UILabel
    
        label1.text = self.dataArray[indexPath.row].title
        label2.text = self.dataArray[indexPath.row].date
        label3.text = self.dataArray[indexPath.row].tag
//        if self.dataArray[indexPath.row].done == true{
//            check.isHidden = false
//        }
        return cell!
    }
}

extension ShowDoneViewController: UITableViewDelegate{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Editfeeling" {
            let Edit = segue.destination as! EditDoneViewController
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                Edit.Data = dataArray[indexPath.row]
            }
        }
    }
}
