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
    
    var currentIndex: Int!
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "HarenosoraMincho", size: 22)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        
//        UITabBarItemAppearance().selected.iconColor = UIColor(hex: "C0E2A1")
//        UITabBarItemAppearance().selected.titleTextAttributes = [.foregroundColor: UIColor(hex: "C0E2A1")]
        
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.sectionInset = UIEdgeInsets(top: 24, left: 30, bottom: 24, right: 30)
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
    
    @objc func getIndex(sender:UIButton){
        currentIndex = Int(sender.currentTitle!)
        deleteDone()
    }
    
    func deleteDone(){
        let id = self.dataArray[currentIndex!].id!
        let dialog = UIAlertController(title: "削除", message: "本当に削除しますか？", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action) in
            self.db.collection("users").document(currentUser!.uid).collection("dones").document(id).delete() { err in
                    if let err = err {
                        let dialog = UIAlertController(title: "削除失敗", message: err.localizedDescription, preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    } else {
                        self.collectionView.reloadData()
                    }
            }
        }))
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        present(dialog, animated: true, completion: nil)
     }

}

extension ShowDoneViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.dataArray.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DoneCell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 12
            cell.layer.shadowOpacity = 0.4
            cell.layer.shadowRadius = 12
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 4, height: 4)
            cell.layer.masksToBounds = false
            let label1 = cell.contentView.viewWithTag(1) as! UILabel
            let label2 = cell.contentView.viewWithTag(2) as! UILabel
            let icon = cell.contentView.viewWithTag(3) as! UIImageView
            let button = cell.contentView.viewWithTag(4) as! UIButton
            button.setTitle("\(indexPath.row)", for: .normal)
            button.addTarget(self, action: #selector(getIndex(sender:)), for: .touchUpInside)
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
