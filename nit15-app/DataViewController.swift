//
//  DataViewController.swift
//  nit15-app
//
//  Created by 澤田昂明 on 2017/01/06.
//  Copyright © 2017年 takarki. All rights reserved.
//

import UIKit
import Firebase

class DataViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    //フラッグ一覧を表示するcollectionview
    @IBOutlet var collectionView:UICollectionView!
    
    let ref = FIRDatabase.database().reference()    //FirebaseDatabaseのルートを設定
    //timerとパイロンの初期状態を宣言
    var timeState:Int = 0
    var pylonState:Int = 0
    
    //コレクションビューで表示するフラッグ画像の配列
    var flagImage:[UIImage] = [UIImage(named:"チェッカーフラッグのフリーアイコン3.png")!]
    
    //タイマー関連
    //タイマーを初期化
    var timer:Timer = Timer()
    //増える数字
    var count:Float = 0
    //LabelForTimer
    @IBOutlet var timeLabel:UILabel!
    @IBOutlet var pylonCountLabel:UILabel!  //倒したパイロンの数を表示
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //collectionViewのデータベースとデリゲードを宣言
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    //パイロンボタンを押したとき
    @IBAction func pylon(){
        //timerがセットされている時しか動作しない
        if timeState == 1{
            pylonState = pylonState + 1
        }else{
            //時間がセットされていない時
            pylonState = 0
        }
        //パイロンの個数を表示
        pylonCountLabel.text = "×\(pylonState)"
        //パイロンの数を送信
        self.create()
    }
    
    @IBAction func timerWill(){
        if timeState == 0{
            timeState = 1
        }else{
            timeState = 0
        }
        //Firebaseにタイマーがオンになっていることを送信する
        self.create()
        //タイマーを作動させる
        self.timerFunc()
        
        
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
        if timeState == 1{
            count = count + 0.01
        }
        timeLabel.text = "\(count)s"
    }
    
    //データ送信のメソッド
    func create(){
        //ログインしているユーザーのIDをchildにしてユーザーデータを作成
        //childByAutoID()でユーザーIDの下に，IDを自動生成してその中にデータを入れる
        self.ref.child((FIRAuth.auth()?.currentUser?.uid)!).childByAutoId().setValue(["time":timeState,"pylon":pylonState, "date": FIRServerValue.timestamp()])
        
        
    }
    
    //CollectionViewの必須メソッド
    //セルの数を返すメソッド
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    //セルに表示するものを返すメソッド
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FlagCollectionViewCell
        
        cell.imageView.image = flagImage[indexPath.row]
        
        return cell
    }
    //セルが選択された時の動作
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.row)が選択")
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
