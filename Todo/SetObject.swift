//
//  SetObject.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/16.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
//delegateはweak参照したいため、classを継承する
protocol SignUpDelegate: class {
    func createUserToFirestoreAction()
    func completedRegisterUserInfoAction()
    func showAlert(error: String?)
}

class DataObject: NSObject{
    var title: String?
    var timelimit: String?
    var detail: String?
    var done: Bool?
    var id: String?
    
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        
//        let dateValue = (data["timelimit"] as! Timestamp).dateValue()
//        let f = DateFormatter()
//        f.locale = Locale(identifier: "ja_JP")
//        f.dateStyle = .long
//        f.timeStyle = .none
//        let date = f.string(from: dateValue)
        
        
        self.title = data["title"] as? String
        self.timelimit = data["timelimit"] as? String
        self.detail = data["detail"] as? String
        self.done = data["done"] as? Bool
        self.id = document.documentID
    }

}

class SignUp {

    // delegateはメモリリークを回避するためweak参照する
    weak var delegate: SignUpDelegate?

    func createUser(email: String, password: String) {
        // FirebaseAuthへ保存
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("FirebaseAuthへの保存に失敗しました。\(err)")
                self.delegate?.showAlert(error: err.localizedDescription.description)
                return
            }
            print("FirebaseAuthへの保存に成功しました。")
            self.delegate?.createUserToFirestoreAction()
        }
    }


    func createUserInfo(uid: String, docDate: [String : Any]) {
        // FirebaseFirestoreへ保存
        Firestore.firestore().collection("users").document(uid).setData(docDate as [String : Any]) { (err) in
            if let err = err {
                print("Firestoreへの保存に失敗しました。\(err)")
                self.delegate?.showAlert(error: err.localizedDescription.description)
                return
            }
            print("Firestoreへの保存に成功しました。")
            self.delegate?.completedRegisterUserInfoAction()
        }
    }

}
