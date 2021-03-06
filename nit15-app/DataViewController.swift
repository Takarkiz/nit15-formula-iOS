//
//  DataViewController.swift
//  nit15-app
//
//  Created by 澤田昂明 on 2017/01/06.
//  Copyright © 2017年 takarki. All rights reserved.
//

import UIKit
import Firebase
import SystemConfiguration

class DataViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    //フラッグ一覧を表示するcollectionview
    @IBOutlet var collectionView:UICollectionView!
    
    let ref = FIRDatabase.database().reference()    //FirebaseDatabaseのルートを設定
    //timerとパイロンの初期状態を宣言
    var timeState:Int = 0
    var pylonState:Int = 0
    var flagState:Int = 99
    
    //スワイプのインスタンスを宣言
    var swipe:UISwipeGestureRecognizer?
    
    //コレクションビューで表示するフラッグ画像の配列
    var flagImage:[UIImage] = [UIImage(named:"チェッカーフラッグのフリーアイコン3.png")!,UIImage(named:"flag-green.jpg")!,UIImage(named:"flag-orangeBall.jpg")!,UIImage(named:"flag-blue.jpg")!,UIImage(named:"flag-yellow.jpg")!,UIImage(named:"flag-red.jpg")!,UIImage(named:"flag-black.jpg")!]
    
    //タイマー関連
    //タイマーを初期化
    var timer:Timer = Timer()
    //増える数字
    var count:Float = 0
    //ラップタイムを記録する配列
    var rapTimeArray:[Float] = []
    
    //LabelForTimer
    @IBOutlet var timeLabel:UILabel!
    @IBOutlet var pylonCountLabel:UILabel!  //倒したパイロンの数を表示
    @IBOutlet var rapTimeLabel:UILabel! //ラップタイムを表示
    @IBOutlet var timerStartButton:UIButton! //ボタン
    @IBOutlet var rapButton:UIButton!   //ラップする時用のボタン
    @IBOutlet var stopButton:UIButton!  //ストップする用のボタン
    @IBOutlet var nowFlag:UIImageView!  //今のフラッグを確認用で表示
    @IBOutlet var lapCount:UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //collectionViewのデータベースとデリゲードを宣言
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //ボタンの設定
        self.buttonSetting()
        
        //ナビゲーションバーを隠す
        //self.hideTabber()
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
        if timeState >= 1{
            pylonState = pylonState + 1
        }else{
            //時間がセットされていない時
            pylonState = 0
        }
        //パイロンの個数を表示
        pylonCountLabel.text = "×\(pylonState)"
        //パイロンの数を送信
        self.create(wheres: "runinfo",count: rapTimeArray.last!)
    }
    
    @IBAction func pylonButtonDid(){
        let temp = pylonState
        pylonState = 0
        self.create(wheres: "runinfo",count: rapTimeArray.last!)
        pylonState = temp
    }
    
    @IBAction func timerWill(){
        //作動状態に変更
        timeState = 1
        //何周目かを表示
        lapCount.text = "lap:\(timeState)"
        
        //隠してラップ，終了ボタンを表示
        timerStartButton.isHidden = true
        rapButton.isHidden = false
        stopButton.isHidden = false
        
        //Firebaseにタイマーがオンになっていることを送信する
        self.create(wheres: "runinfo",count: count)
        
        //タイマーの処理を開始
        timerAction()
    }
    
    //タイマーのオン・オフを切り替えるメソッド
    func timerAction(){
        if !timer.isValid{
            //タイマーが作動してなかったら動かす
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.up), userInfo: nil, repeats: true)
        }
    }
    
    //タイマーの数を繰り上げ，表示する関数
    func up(){
        if timeState != 0{
            count = count + 0.01
        }
        timeLabel.text = String(format: "%.2fs", count)
    }
    
    
    //ラップタイムボタンを選択時
    @IBAction func rapButtonWill(){
        //タイマーの状態を変更
        timeState += 1
        //何周目か
        lapCount.text = "lap:\(timeState)"
        //変更を送信
        let temp = pylonState
        pylonState = 0
        self.create(wheres: "runinfo",count: count)
        pylonState = temp
        //現在のcountをラップタイムの配列に入れる
        rapTimeArray.append(count)
        
        //カウントは初期化
        count = 0
        
        //ラップタイムラベルにラップタイムを表示
        rapTimeLabel.text = String(format:"%.2fs", rapTimeArray.last!)

    }
    
    //ストップボタンを押した時
    @IBAction func stopButtonWill(){
        //タイムの状態を0に戻す
        timeState = 0
        //タイマーを止める
        timer.invalidate()
        //ボタンを消す
        rapButton.isHidden = true
        stopButton.isHidden = true
        //ボタンを表示
        timerStartButton.isHidden = false
        //countを初期化
        count = 0
        timeLabel.text = String(count)
        flagState = 99
        pylonState = 0
        //stopボタンが押されたことを通知する
        self.create(wheres: "runinfo",count: count)
        self.finish()
        
    }
    
    
    
    //データ送信のメソッド
    func create(wheres:String,count:Float){
        
        //現在ログインしているユーザーがいるかどうかを判別する
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            //ログインしているユーザーのIDをchildにしてユーザーデータを作成
            //childByAutoID()でユーザーnameの下に，IDを自動生成してその中にデータを入れる
            self.ref.child((user.displayName)!).child(wheres).childByAutoId().updateChildValues(["state":timeState,"pylon":pylonState,"flag":flagState,"time":count*100,"lap":timeState])
            
        } else {
            //ユーザーがログインしていない場合
            return
        }
    }
    
    //データ送信のメソッド，結果用
    func finish(){
        
        //現在ログインしているユーザーがいるかどうかを判別する
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            //ログインしているユーザーのIDをchildにしてユーザーデータを作成
            //childByAutoID()でユーザーnameの下に，IDを自動生成してその中にデータを入れる
            self.ref.child((user.displayName)!).child("finish").childByAutoId().setValue(["time":rapTimeArray, "date":getToday()])
        } else {
            //ユーザーがログインしていない場合zgrfe
            return
        }
    }
    
    //戻る
    func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //CollectionViewの必須メソッド
    //セルの数を返すメソッド
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flagImage.count
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
        flagState = indexPath.row
        let temp = pylonState
        pylonState = 0
        if indexPath.row != 5{
            nowFlag.isHidden = false
            nowFlag.image = flagImage[indexPath.row]
        }else if indexPath.row == 5{
            nowFlag.isHidden = true
        }
        self.create(wheres: "runinfo",count: rapTimeArray.last!)
        pylonState = temp
    }
    
    
    //ネットワークに接続しているか確認
    func checkReachability(host_name:String) -> Bool{
        let reachability = SCNetworkReachabilityCreateWithName(nil, host_name)!
        var flags = SCNetworkReachabilityFlags.connectionAutomatic
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func getToday(format:String = "yyyy/MM/dd HH:mm:ss") -> String {
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: now as Date)
    }
    
    
    func buttonSetting(){
        //ボタンの見た目の設定->丸に
        timerStartButton.layer.masksToBounds = true //枠を丸く
        timerStartButton.layer.cornerRadius = 60.0  //枠の半径
        timerStartButton.layer.borderWidth = 3.0
        timerStartButton.layer.borderColor = UIColor.black.cgColor
        //ラップボタンに関して
        rapButton.layer.masksToBounds = true //枠を丸く
        rapButton.layer.cornerRadius = 60.0  //枠の半径
        rapButton.layer.borderWidth = 3.0
        rapButton.layer.borderColor = UIColor.black.cgColor
        //ストップボタンに関して
        stopButton.layer.masksToBounds = true //枠を丸く
        stopButton.layer.cornerRadius = 60.0  //枠の半径
        stopButton.layer.borderWidth = 3.0
        stopButton.layer.borderColor = UIColor.black.cgColor
        
        //初期画面ではラップとストップボタンを消す
        rapButton.isHidden = true
        stopButton.isHidden = true
    }
    
    
}
