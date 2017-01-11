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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //textFieldのdelegateを宣言
        mailTextField.delegate = self
        passTextField.delegate = self

    }
    
    //完了ボタンをタップした時の動作
    @IBAction func add(){
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    


}
