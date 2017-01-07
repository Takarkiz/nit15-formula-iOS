//
//  EditViewController.swift
//  nit15-app
//
//  Created by 澤田昂明 on 2017/01/06.
//  Copyright © 2017年 takarki. All rights reserved.
//

import UIKit
import Firebase

class EditViewController: UIViewController,UITextFieldDelegate {
    
    //textFieldの宣言
    @IBOutlet var nameTextField:UITextField!
    
    let defaults:UserDefaults = UserDefaults.standard
    
    //現在ログインしているユーザーの情報をuserに代入
    let user = FIRAuth.auth()?.currentUser

    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //完了ボタン
    @IBAction func finish(){
        self.editProfile()
    }
    
    //ユーザー情報の更新
    func editProfile(){
        //名前が入力されていない場合処理を終了する
        guard let name = nameTextField.text else {  return  }
        //ユーザー情報の更新を行う
        if let user = user{
            //プロフィールを更新するの必要なインスタンスを生成
            let changeRequest = user.profileChangeRequest()
            //プロフィール名を変更する
            changeRequest.displayName = name
            //変更のリクエストを送信する
            changeRequest.commitChanges { error in
                if let error = error{
                    //エラー発生時にログを表示
                    print("\(error.localizedDescription)")
                }else{
                    //エラーが起きなかった時
                    //userNameをローカルに保存する
                    self.saveName(name:name)
                    //エラーが起きなかった場合
                    self.transition()
                }
            }
        }
    }
    
    func transition(){
        performSegue(withIdentifier: "toStart", sender: nil)
    }
    
    //Returnキーでキーボードを下ろす
    func textFieldShouldReturn(_ textField:UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    //名前が入った変数を渡し，名前を保存する処理を行う
    func saveName(name:String){
        //名前を格納する配列を準備し，入力された名前を挿入する
        var nameArray:[String] = []
        //以前に保存されたデータがあるかどうかを判別し，あれば追加する
        if let pA = defaults.object(forKey: "namekey"){
            nameArray = pA as! [String]
        }
        nameArray.append(name)
        
        
        //保存する処理
        defaults.set(nameArray, forKey: "namekey")
        defaults.synchronize()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
