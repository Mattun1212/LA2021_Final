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
    
    //@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 175, height: 175)
        layout.sectionInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        collectionView.collectionViewLayout = layout
        
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
                                    self.collectionView.reloadData()
                                 }
                               }
                           }
                       }
           
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.dataArray == [] {
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            listener?.remove()
    }

}

extension ShowDoneViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.dataArray.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DoneCell", for: indexPath)
            cell.layer.borderWidth = 2.0
            let label1 = cell.contentView.viewWithTag(1) as! UILabel
            let label2 = cell.contentView.viewWithTag(2) as! UILabel
            let icon = cell.contentView.viewWithTag(3) as! UIImageView
            
            label1.text = self.dataArray[indexPath.row].title
            let date = self.dataArray[indexPath.row].date
            let arr:[String] = date?.components(separatedBy: "-") ?? ["-","-","-"]
            label2.text = "\(arr[1])/\(arr[2])"
            let tag = self.dataArray[indexPath.row].tag
            icon.image = UIImage(named: tag ?? "その他")

            return cell
        }
}

extension ShowDoneViewController: UICollectionViewDelegate{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Editfeeling" {
            let Edit = segue.destination as! EditDoneViewController
            if let indexPath = collectionView.indexPath(for: sender as! UICollectionViewCell) {
                Edit.Data = dataArray[indexPath.row]
            }
        }
    }
}
