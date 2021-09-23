//
//  ShowTodoViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/16.
//

import UIKit
import Firebase
import FirebaseFirestore
import SnapKit

class ShowTodoViewController: UIViewController {
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    var dataArray: [DataObject] = []
    var listener1: ListenerRegistration?
    var listener2: ListenerRegistration?
    var Id: DocumentReference?
    var successTimes: Int!
    var currentDaruma: Int!
    var feeling:String!
    
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
        
        listener1 = db.collection("users").document(currentUser!.uid).addSnapshotListener { [self] documentSnapshot, error in
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
     
        listener2 = db.collection("users").document(currentUser!.uid).collection("todos").addSnapshotListener { [self] documentSnapshot, error in
                       if let error = error {
                           print("ドキュメントの取得に失敗しました", error)
                       } else {
                        self.dataArray = []
                           if let documentSnapshots = documentSnapshot?.documents {
                               for document in documentSnapshots {
                                let TodoData = DataObject(document: document)
                                self.dataArray.append(TodoData)
                                checkTimelimit()
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
        checkTimelimit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener1?.remove()
        listener2?.remove()
    }
    
    func setDaruma(){
        if currentDaruma == 3{
            currentDaruma = 0
            successTimes += 1
        }else{
            currentDaruma += 1
        }
    }
    
    func done(data: DataObject){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: Date())
        
        let dialog = UIAlertController(title: "完了する", message: "感想を書いて完了させる" + "\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 6
        textView.delegate = self
        // textView を追加して Constraints を追加
        dialog.view.addSubview(textView)
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(75)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-60)
        }

        // 画面が開いたあとでないと textView にフォーカスが当たらないため、遅らせて実行する
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            textView.becomeFirstResponder()
        }
        
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action) in
            let feelingText = textView.text
         if feelingText != "" {
            self.db.collection("users").document(currentUser!.uid).collection("dones").document(data.id!).setData(["title": data.title!, "tag": data.tag!, "feeling": feelingText!, "date": date]) { [self] err in
                if let err = err { // エラーハンドリング
                    let dialog = UIAlertController(title: "doneデータ登録失敗", message: err.localizedDescription, preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(dialog, animated: true, completion: nil)
                } else { // 書き換え成功ハンドリング
                    db.collection("users").document(currentUser!.uid).collection("todos").document(data.id!).delete(){ err in
                        if let err = err { // エラーハンドリング
                            let dialog = UIAlertController(title: "todoデータ削除失敗", message: err.localizedDescription, preferredStyle: .alert)
                            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            present(dialog, animated: true, completion: nil)
                        } else {
                            self.collectionView.reloadData()
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
            }
         }else{
            let dialog = UIAlertController(title: "完了失敗", message: "感想を入力してください", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(dialog, animated: true, completion: nil)
         }
            
        }))
        
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(dialog, animated: true, completion: nil)
    }
    
    func deleteTodo(id: String){
        let dialog = UIAlertController(title: "削除", message: "削除すると現在のだるま落としがやり直しになりますが本当に削除しますか？", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action) in
            self.db.collection("users").document(currentUser!.uid).collection("todos").document(id).delete() { err in
                    if let err = err {
                        let dialog = UIAlertController(title: "削除失敗", message: err.localizedDescription, preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    } else {
                        self.collectionView.reloadData()
                        self.db.collection("users").document(currentUser!.uid).updateData(["currentDaruma": 0]){ err in
                                if let err = err { // エラーハンドリング
                                    print("Error updating document: \(err)")
                                } else { // 書き換え成功ハンドリング
                                    print("Update successfully!")
                                }
                        }
                    }
                    
            }
        }))
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        present(dialog, animated: true, completion: nil)
    }
    
    
   @IBAction func handleAction(_ sender: UICollectionViewCell){
        let actionSheet = UIAlertController(title: "Menu", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
    
        let action1 = UIAlertAction(title: "Doneにする", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            let data = self.dataArray[sender.tag]
            self.done(data: data)
        })
       
        let action2 = UIAlertAction(title: "削除する", style: UIAlertAction.Style.destructive, handler: {
            (action: UIAlertAction!) in
            let cellId = self.dataArray[sender.tag].id
            self.deleteTodo(id: cellId!)
        })

        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func checkTimelimit(){
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        for data in dataArray {
            let timelimit = formatter.date(from: data.timelimit!)!
            let dialog = UIAlertController(title: "失敗", message: "期限を守れなかったのでだるま落としに失敗しました。。。", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action) in
                self.db.collection("users").document(currentUser!.uid).updateData(["currentDaruma": 0]){ err in
                        if let err = err { // エラーハンドリング
                            print("Error updating document: \(err)")
                        } else { // 書き換え成功ハンドリング
                            print("Update successfully!")
                        }
                    }
                        
                }))

            if timelimit < Date(){
                db.collection("users").document(currentUser!.uid).collection("todos").document(data.id!).delete(){ err in
                    if let err = err { // エラーハンドリング
                       print("Error updating document: \(err)")
                    } else { // 書き換え成功ハンドリング
                       self.collectionView.reloadData()
                       self.present(dialog, animated: true, completion: nil)
                    }
                }
            }
        }
        
    }
    
}

extension ShowTodoViewController:UICollectionViewDelegate{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit" {
            let Edit = segue.destination as! EditTodoViewController
            if let indexPath = collectionView.indexPath(for: sender as! UICollectionViewCell) {
                Edit.Data = dataArray[indexPath.row]
            }
        }
    }
}

extension ShowTodoViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.dataArray.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodoCell", for: indexPath)
            cell.layer.borderWidth = 2.0
            let label1 = cell.contentView.viewWithTag(1) as! UILabel
            let label2 = cell.contentView.viewWithTag(2) as! UILabel
            let icon = cell.contentView.viewWithTag(3) as! UIImageView
            cell.tag = indexPath.row + 1
            label1.text = self.dataArray[indexPath.row].title
            let arr:[String] = self.dataArray[indexPath.row].timelimit!.components(separatedBy: "-")
            label2.text = "\(arr[1])/\(arr[2])まで"
            icon.image = UIImage(named: self.dataArray[indexPath.row].tag!)
            
            return cell
        }
}

extension ShowTodoViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        feeling = textView.text
    }

}
