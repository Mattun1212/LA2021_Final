//
//  SignUpViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/16.
//

import UIKit
import AuthenticationServices
import Firebase
import FirebaseAuth
import CryptoKit
import IQKeyboardManager
import FirebaseFirestore


class SignUpViewController: UIViewController{
    
    let alert: Alert = Alert()
    let signUp = SignUp()
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var RegisterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        nameTextField.delegate = self
        signUp.delegate = self
        
        passwordTextField.isSecureTextEntry = true
        
        RegisterButton.isEnabled = false
    }
    
    @IBAction func signup(_ sender: Any) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text
        else { return }
        
        signUp.createUser(email: email, password: password)
       
    }
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    
    private func createUserToFirestore() {

           guard let email = Auth.auth().currentUser?.email,
                 let uid = Auth.auth().currentUser?.uid,
                 let userName = self.nameTextField.text
           else { return }

           // 保存内容を定義する（辞書型）
           let docData = ["email": email,
                          "userName": userName,
                          "currentDaruma": 0,
                          "successTimes": 0,
                          "createdAt": Timestamp()] as [String : Any?]

           // FirebaseFirestoreへ保存
           signUp.createUserInfo(uid: uid, docDate: docData as [String : Any])
       }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension SignUpViewController: UITextFieldDelegate {
    
    // textFieldでテキスト選択が変更された時に呼ばれるメソッド
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // textFieldが空かどうかの判別するための変数(Bool型)で定義
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        let userNameIsEmpty = nameTextField.text?.isEmpty ?? true
        // 全てのtextFieldが記入済みの場合の処理
        if emailIsEmpty || passwordIsEmpty || userNameIsEmpty {
            RegisterButton.isEnabled = false
//            RegisterButton.backgroundColor = UIColor.systemGray2
        } else {
            RegisterButton.isEnabled = true
//            RegisterButton.backgroundColor = UIColor(named: "lineGreen")
        }
    }

    // textField以外の部分を押したときキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SignUpViewController: SignUpDelegate {
    func createUserToFirestoreAction() {
        print("FirebaseAuthへの保存に成功しました。")
        self.createUserToFirestore()
    }
    
    func completedRegisterUserInfoAction() {
        self.performSegue(withIdentifier: "toTodo", sender: nil)
    }
    
    func showAlert(error: String?){
        let dialog = self.alert.fail(titleText: "新規登録失敗", actionTitleText: "OK", message: error!)
        self.present(dialog, animated: true, completion: nil)
    }
}
