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
import Lottie
import AVFoundation

class ShowTodoViewController: UIViewController {
    
    var animationView = AnimationView()
    var seAudioPlayer: AVAudioPlayer?
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    var dataArray: [DataObject] = []
    var listener1: ListenerRegistration?
    var listener2: ListenerRegistration?
    var Id: DocumentReference?
    var successTimes: Int!
    var currentDaruma: Int!
    var feeling:String!
    var currentIndex: Int!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "HarenosoraMincho", size: 22)!, NSAttributedString.Key.foregroundColor: UIColor.white]

        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.sectionInset = UIEdgeInsets(top: 24, left: 30, bottom: 24, right: 30)
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
        
        let dialog = UIAlertController(title: "完了する", message: "感想を書いて完了させる", preferredStyle: .alert)
        
        dialog.addTextField(configurationHandler: {(textField) -> Void in
            textField.delegate = self
        })
        
        
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action) in
         if feeling != "" {
            self.db.collection("users").document(currentUser!.uid).collection("dones").document(data.id!).setData(["title": data.title!, "tag": data.tag!, "feeling": feeling!, "date": date]) { [self] err in
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
                            addAnimationView()
                            
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
                                    let dialog = UIAlertController(title: "だるま落とし失敗", message: "だるま落としが\n最初からやり直しになりました。。。", preferredStyle: .alert)
                                    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    collapseAnimationView()
                                    animationView.play { finished in
                                        if finished {
                                            self.animationView.removeFromSuperview()
                                            present(dialog, animated: true, completion: nil)
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        self.playSE(fileName: "collapse")
                                    }
                                }
                        }
                    }
                    
            }
        }))
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        present(dialog, animated: true, completion: nil)
    }
    
    @objc func getIndex(sender:UIButton){
        currentIndex = Int(sender.currentTitle!)
        handleAction()
    }
    
    func handleAction(){
  
        let actionSheet = UIAlertController(title: "Menu", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
    
        let action1 = UIAlertAction(title: "完了する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            let data = self.dataArray[self.currentIndex]
            self.done(data: data)
        })
       
    let action2 = UIAlertAction(title: "削除する", style: UIAlertAction.Style.destructive, handler: {
            (action: UIAlertAction!) in
        let cellId = self.dataArray[self.currentIndex].id
            self.deleteTodo(id: cellId!)
        })

        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
    
        if UIDevice.current.userInterfaceIdiom == .pad {
            actionSheet.popoverPresentationController?.sourceView = self.view
            let screenSize = UIScreen.main.bounds
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,y: screenSize.size.height,width: 0,height: 0)
        }
    
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func checkTimelimit(){
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        for data in dataArray {
            let timelimit = formatter.date(from: data.timelimit!) ?? Date()
            let dialog = UIAlertController(title: "失敗", message: "期限を守れなかったので\nだるま落としに失敗しました。。。", preferredStyle: .alert)
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
                        self.collapseAnimationView()
                        self.animationView.play { finished in
                            if finished {
                                self.animationView.removeFromSuperview()
                                self.present(dialog, animated: true, completion: nil)
                            }
                        }
                        self.playSE(fileName: "collapse")
                    }
                }
            }
        }
    }
    
    func playSE(fileName: String) {
        
        // サウンドの初期化
        guard let soundFilePath = Bundle.main.path(forResource: fileName, ofType: "mp3") else {
            assert(false, "ファイル名が間違っているので、読み込めません")
            return
        }
        
        let fileURL = URL(fileURLWithPath: soundFilePath)
        
        do {
            seAudioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            seAudioPlayer?.prepareToPlay()
            seAudioPlayer?.play()
        } catch let error {
            assert(false, "サウンドの設定中にエラーが発生しました (\(error.localizedDescription))")
        }
    }
    
    func addAnimationView() {
        if currentDaruma == 0{
            animationView = AnimationView(name: "lf20_2lsutk8e")
        }else if currentDaruma == 1{
            animationView = AnimationView(name: "lf20_n51mt8di")
        }else if currentDaruma == 2{
            animationView = AnimationView(name: "lf20_wotrgcan")
        }else if currentDaruma == 3{
            animationView = AnimationView(name: "lf20_fkse2kbw")
        }
            //アニメーションの位置指定（画面中央）
            animationView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
            animationView.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
            
            animationView.contentMode = .scaleAspectFit
        
            animationView.isUserInteractionEnabled = true
            animationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))

            //ViewControllerに配置
            view.addSubview(animationView)
    }
    
    func collapseAnimationView(){
        animationView = AnimationView(name: "lf20_f3rgysv8")
        animationView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        animationView.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        
        animationView.contentMode = .scaleAspectFit
        view.addSubview(animationView)
    }
    
    @objc func tapped() {
        animationView.play { [self] finished in
         if finished {
            self.animationView.removeFromSuperview()
            if currentDaruma == 0 {
                let dialog = UIAlertController(title: "完了！", message: "だるま落とし成功！！さすがです！！", preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(dialog, animated: true, completion: nil)
            }else{
                let dialog = UIAlertController(title: "完了！", message: "だるま落とし成功まであと\(4-currentDaruma)回！", preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(dialog, animated: true, completion: nil)
            }
        }
       }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.playSE(fileName: "knock")
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
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 12
            cell.layer.shadowOpacity = 0.4
            cell.layer.shadowRadius = 12
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 8, height: 8)
            cell.layer.masksToBounds = false
            let label1 = cell.contentView.viewWithTag(1) as! UILabel
            let label2 = cell.contentView.viewWithTag(2) as! UILabel
            let icon = cell.contentView.viewWithTag(3) as! UIImageView
            let button = cell.contentView.viewWithTag(4) as! UIButton
            button.setTitle("\(indexPath.row)", for: .normal)
            button.addTarget(self, action: #selector(getIndex(sender:)), for: .touchUpInside)
            label1.text = self.dataArray[indexPath.row].title ?? ""
            let arr:[String] = self.dataArray[indexPath.row].timelimit!.components(separatedBy: "-")
            label2.text = "\(arr[1])/\(arr[2])まで"
            icon.image = UIImage(named: self.dataArray[indexPath.row].tag!)
            
            return cell
        }
}


extension ShowTodoViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        feeling = textField.text
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
