//
//  AnotherLoginViewController.swift
//  nit15-app
//
//  Created by 澤田昂明 on 2017/01/11.
//  Copyright © 2017年 takarki. All rights reserved.
//

import UIKit
import Firebase

class AnotherLoginViewController: UIViewController,UITextFieldDelegate {
    
    //メールアドレスを入力するtextField
    @IBOutlet var mailTextField:UITextField!
    //パスワードを入力するtextField
    @IBOutlet var passTextField:UITextField!
    
    //保存のインスタンス
    let defaults:UserDefaults = UserDefaults.standard
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //textFieldのdelegateを宣言
        mailTextField.delegate = self
        passTextField.delegate = self

    }
    
    //完了ボタンをタップした時の動作
    @IBAction func add(){
        self.login()
    }
    
    //ログイン処理
    func login(){
        //未入力の場合は処理を止める
        guard mailTextField.text != nil else {  return  }
        guard passTextField.text != nil else {  return  }
        
        //ログイン
        FIRAuth.auth()?.signIn(withEmail: mailTextField.text!, password: passTextField.text!, completion: {(user,error) in
            //エラーがないか確認
            if error == nil{
                if let loginUser = user{
                    //ログインに完了したら，ローカルに保存
                    self.saveData(mail: self.mailTextField.text!, password: self.passTextField.text!, name: (loginUser.displayName)!)
                    //画面遷移
                    self.transitionStart()
                }
            }else{
                //エラーが発生した時
                print("error...\(error?.localizedDescription)")
            }
        })
    }
    
    //ログイン完了後にスタート画面に戻る
    func transitionStart(){
        performSegue(withIdentifier: "toStart", sender: nil)
    }
    
    //Returnキーでキーボードを下ろす
    func textFieldShouldReturn(_ textField:UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //データを保存するメソッド
    func saveData(mail:String,password:String,name:String){
        
        //それぞれの配列を宣言
        var mailArray:[String] = []
        var passArray:[String] = []
        var nameArray:[String] = []
        
        //事前に保存されたデータがある場合
        if let mA = defaults.object(forKey: "mailkey"){
            mailArray = mA as! [String]
        }
        if let pA = defaults.object(forKey: "passkey"){
            passArray = pA as! [String]
        }
        if let nA = defaults.object(forKey: "namekey"){
            nameArray = nA as! [String]
        }
        
        //それぞれの配列に要素を追加
        mailArray.append(mail)
        passArray.append(password)
        nameArray.append(name)
        //保存する処理
        defaults.set(mailArray, forKey: "mailkey")
        defaults.set(passArray, forKey: "passkey")
        defaults.set(nameArray, forKey: "namekey")
        defaults.synchronize()
    }
    


}
