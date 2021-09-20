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

class DataObject: NSObject{
    var title: String?
    var tag: String?
    var timelimit: String?
    var detail: String?
    var done: Bool?
    var id: String?
    
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.title = data["title"] as? String
        self.tag = data["tag"] as? String
        self.timelimit = data["timelimit"] as? String
        self.detail = data["detail"] as? String
        self.done = data["done"] as? Bool
        self.id = document.documentID
    }

}

class DoneObject: NSObject{
    var title: String?
    var tag: String?
    var date: String?
    var feeling: String?
    var id: String?
    
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.title = data["title"] as? String
        self.tag = data["tag"] as? String
        self.date = data["date"] as? String
        self.feeling = data["feeling"] as? String
        self.id = document.documentID
    }

}


class userInfo: NSObject{
    var userName: String?
    var email: String?
    var docid: String?
    var current: Int?
    var success: Int?
    
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.userName = data["userName"] as? String
        self.email = data["email"] as? String
        self.current = data["currentDaruma"] as? Int
        self.success = data["successTimes"] as? Int
        self.docid = document.documentID
    }

}

//delegateはweak参照したいため、classを継承する
protocol SignUpDelegate: class {
    func createUserToFirestoreAction()
    func completedRegisterUserInfoAction()
    func showAlert(error: String?)
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
