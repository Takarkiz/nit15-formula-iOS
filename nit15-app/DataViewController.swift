//
//  DataViewController.swift
//  nit15-app
//
//  Created by 澤田昂明 on 2017/01/06.
//  Copyright © 2017年 takarki. All rights reserved.
//

import UIKit
import Firebase

class DataViewController: UIViewController {
    
    let ref = FIRDatabase.database().reference()    //FirebaseDatabaseのルートを設定
    var timeState:Int = 0
    var pylonState:Int = 0
    
    //タイマー関連
    //タイマーを初期化
    var timer:Timer = Timer()
    //増える数字
    var count:Float = 0
    @IBOutlet var timeLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear(animated)
    }
    
    @IBAction func back(){
        dismiss(animated: true, completion: nil)
    }
    
    //パイロンボタンを押したとき
    @IBAction func pylon(){
        if pylonState == 0{
            pylonState = 1
        }else{
            pylonState = 0
        }
        self.create()
        
    }
    
    @IBAction func timerWill(){
        if timeState == 0{
            timeState = 1
        }else{
            timeState = 0
        }
        
    }
    
    func timerFunc(){
        if !timer.isValid{
            //タイマーが作動してなかったら動かす
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.up), userInfo: nil, repeats: true)
        }else{
            timer.invalidate()
        }
    }
    
    func up(){
        count = count + 0.01
        timeLabel.text = "\(count)s"
    }
    
    //データ送信のメソッド
    func create(){
        
        //ローとからログインしているユーザーのIDをchildにしてユーザーデータを作成
        //childByAutoID()でユーザーIDの下に，IDを自動生成してその中にデータを入れる
        self.ref.child((FIRAuth.auth()?.currentUser?.uid)!).childByAutoId().setValue(["time":timeState,"pylon":pylonState])
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
