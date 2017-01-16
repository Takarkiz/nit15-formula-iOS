//
//  SigninViewController.swift
//  nit15-app
//
//  Created by 澤田昂明 on 2017/01/06.
//  Copyright © 2017年 takarki. All rights reserved.
//

import UIKit
import Firebase //Firebaseをインポート

class SigninViewController: UIViewController,UITextFieldDelegate {
    
    //メール用のフォーム
    @IBOutlet var mailTextField:UITextField!
    //パスワード用のフォーム
    @IBOutlet var passTextField:UITextField!
    
    //ローカルに保存するためにNSUserdefaultを宣言
    let defaults:UserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TextFieldのデリゲードメソッドを宣言
        mailTextField.delegate = self
        passTextField.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //サインアップを行う
    @IBAction func signUpStart(){
        self.signup()
    }
    
    //ログイン画面へ
    @IBAction func tologinTransition(){
        performSegue(withIdentifier: "login", sender: nil)
    }
  
    func transitionDetailEdit(){
        self.performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    //Returnキーでキーボードを隠す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //サインアップのためのメソッド
    func signup(){
        
        //入力されていない場合はその後の処理を行わない
        guard let mail = mailTextField.text else {  return  }
        guard let password = passTextField.text else {  return  }
        
        //FIRAuth.auth()?.creatUserWithEmailでサインアップ
        //第一引数にEmail,第二引数にパスワード
        FIRAuth.auth()?.createUser(withEmail: mail, password: password, completion: {(user,error) in
            if error == nil{
                //エラーが発生しなかった場合
                //メールとパスを保存する関数を呼ぶ
                self.saveData(mail:mail,password:password)
                //そのままログインも行う
                self.login()
            }else{
                print("\(error?.localizedDescription)")
            }
        })
    }
    
    //ログイン処理
    func login(){
        
        //ログイン
        FIRAuth.auth()?.signIn(withEmail: mailTextField.text!, password: passTextField.text!, completion: {(user,error) in
            //エラーがないか確認
            if error == nil{
                if let loginUser = user{
                    self.transitionDetailEdit()
                }
            }else{
                //エラーが発生した時
                print("error...\(error?.localizedDescription)")
            }
        })
    }
    
    //データを保存するメソッド
    func saveData(mail:String,password:String){
        
        //それぞれの配列を宣言
        var mailArray:[String] = []
        var passArray:[String] = []
        
        //事前に保存されたデータがある場合
        if let mA = defaults.object(forKey: "mailkey"){
            mailArray = mA as! [String]
        }
        if let pA = defaults.object(forKey: "passkey"){
            passArray = pA as! [String]
        }
        
        //それぞれの配列に要素を追加
        mailArray.append(mail)
        passArray.append(password)
        //保存する処理
        defaults.set(mailArray, forKey: "mailkey")
        defaults.set(passArray, forKey: "passkey")
        defaults.synchronize()
    }

}
