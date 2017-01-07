//
//  StartViewController.swift
//  nit15-app
//
//  Created by 澤田昂明 on 2017/01/06.
//  Copyright © 2017年 takarki. All rights reserved.
//

import UIKit
import Firebase

class StartViewController: UIViewController {
    
    //ローカルに保存されたユーザがいるかを確認する用
    let defaults:UserDefaults = UserDefaults.standard
    
    //現在のログイン状態を示すラベル
    @IBOutlet var stateLabel:UILabel!
    
    //現在ログインしているユーザーを取得する
    func getNowLoginUser(){
        if let user = FIRAuth.auth()?.currentUser {
            //ユーザーがログインしている場合
            stateLabel.text = "現在 \(user.displayName)がログイン"
        }else{
            //誰もログインしていない場合
            stateLabel.text = "未ログイン"
        }
    }
    
    //ビューが呼ばれるたびに呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear(animated)
        //現在ログインして入るユーザーがいるかどうか判定
        self.getNowLoginUser()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //サインイン画面に遷移する
    func transitionToSignin(){
        performSegue(withIdentifier: "toSignin", sender: nil)
    }
    
    //ログイン画面に行く
    func transitionToLogin(){
        performSegue(withIdentifier: "toLogin", sender: nil)
    }
    
    //ユーザー画面に行く際に保存されたユーザーがいるかどうかで，遷移先を変える
    @IBAction func authControl(){
        if let user = defaults.object(forKey: "namekey"){
            self.transitionToLogin()
        }else{
            self.transitionToSignin()
        }
    }
    
    //新規ユーザー登録をする際のアラート
    func alartAuth(){
        
    }


}
