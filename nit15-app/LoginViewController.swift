//
//  LoginViewController.swift
//  nit15-app
//
//  Created by 澤田昂明 on 2017/01/06.
//  Copyright © 2017年 takarki. All rights reserved.
//

import UIKit
import Firebase //Firebaseをインポート

class LoginViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var table:UITableView!
    
    //ローカルん保存したusernameを取り出すために，UserDefaultを呼び出す
    let defaults:UserDefaults = UserDefaults.standard
    
    var nameArray:[String] = []
    var mailArray:[String] = []
    var passArray:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        self.reload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //配列にローカルに保存したデータを格納する
    func reload(){
        if let tempArray = defaults.array(forKey: "namekey"){
            nameArray = tempArray as! [String]
        }else{
            nameArray.append("none")
        }
        
        //ローカルに保存しているデータを戻す
        mailArray = defaults.array(forKey: "mailkey") as! [String]
        passArray = defaults.array(forKey: "passkey") as! [String]
        
        //確認
        print("\(nameArray)")
        print("\(mailArray)")
        print("\(passArray)")
    }
    
    //セルがタップされた時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //配列に正しいデータが入っている場合のみに処理を続ける
        if nameArray[0] != "none"{
            self.selectedRow(num: indexPath)
        }
    }
    
    //セルに何を表示するか
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        cell?.textLabel?.text = nameArray[indexPath.row]
        return cell!
    }
    
    
    //セルの数を設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    //現在ログインしているユーザーを取得する
    func getNowLoginUser(){
        if let user = FIRAuth.auth()?.currentUser{
            //ログイン中の場合
            self.logout()
        }else{
            //ログインしていない場合
        }
    }
    
    //ログアウトする処理
    func logout(){
        do{
            try FIRAuth.auth()?.signOut()
            print("ログアウト完了")
        }catch let error as NSError{
            print("\(error.localizedDescription)")
        }
    }
    
    //ログインするためのメソッド
    func login(email:String,password:String){
        
        //signInwithEmailでログイン
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {(user, error) in
            //エラーがないか確認
            if error == nil{
                if let loginUser = user{
                    print("ログイン完了")
                    //ログイン完了後にはスタート画面へ
                    self.toStartView()
                }
            }else{
                print("error...\(error?.localizedDescription)")
            }
        })
    }
    
    func selectedRow(num:IndexPath){
        //現在ログインしているアカウントからログアウトする処理を行う
        self.getNowLoginUser()
        //選択したセルのアカウントにログインする
        self.login(email: mailArray[num.row], password: passArray[num.row])
        
    }
    
    //スタート画面への画面遷移
    func toStartView(){
        performSegue(withIdentifier: "toStart", sender: nil)
    }
    
    @IBAction func add(){
        performSegue(withIdentifier: "add", sender: nil)
    }
    
    //セルを削除する許可を与えるメソッド
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //セルの削除ボタンが押された時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            nameArray.remove(at: indexPath.row)
            mailArray.remove(at: indexPath.row)
            passArray.remove(at: indexPath.row)
            //セルを削除
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            //Useridを削除しない
            //self.deleteUserId()
            //削除したら保存
            defaults.set(nameArray, forKey: "namekey")
            defaults.set(mailArray, forKey: "mailkey")
            defaults.set(passArray, forKey: "passkey")
        }
    }
    
    //ユーザーの削除
    func deleteUserId(){
        let user = FIRAuth.auth()?.currentUser
        
        user?.delete { error in
            if let error = error{
                //エラー発生時
            }else{
                //エラーが出なかったら
                print("削除完了")
            }
        }
    }
    
    @IBAction func allDelete(){
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
    }
    

}
