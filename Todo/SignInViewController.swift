//
//  SignInViewController.swift
//  Todo
//
//  Created by Koutaro Matsushita on 2021/09/16.
//

import UIKit
import Firebase
import FirebaseAuth

class SignInViewController: UIViewController {

    let alert: Alert = Alert()
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    
    override func viewDidLoad() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        passwordTextField.isSecureTextEntry = true
        
        LoginButton.isEnabled = false
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func signIn(_ sender: Any) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text
        else { return }
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if (result?.user) != nil {
                    self.performSegue(withIdentifier: "toTodo", sender: nil)
                } else if error != nil {
                    let dialog = self.alert.fail(titleText: "ログイン失敗", actionTitleText: "OK", message: (error?.localizedDescription.description)!)
                    self.present(dialog, animated: true, completion: nil)
                }
            }
       
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


}

extension SignInViewController: UITextFieldDelegate {
    // textFieldでテキスト選択が変更された時に呼ばれるメソッド
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // textFieldが空かどうかの判別するための変数(Bool型)で定義
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        // 全てのtextFieldが記入済みの場合の処理
        if emailIsEmpty || passwordIsEmpty {
            LoginButton.isEnabled = false
//            LoginButton.backgroundColor = UIColor.systemGray2
        } else {
            LoginButton.isEnabled = true
//            LoginButton.backgroundColor = UIColor(named: "lineGreen")
        }
    }

    // textField以外の部分を押したときキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
