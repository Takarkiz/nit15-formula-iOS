//
//  ViewController.swift
//  nit15-app
//
//  Created by 澤田昂明 on 2016/12/03.
//  Copyright © 2016年 takarki. All rights reserved.
//

import UIKit
import CoreBluetooth
import Firebase

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate{
    
    private var centralManager:CBCentralManager!
    private var peripheral:CBPeripheral!
    private var peripherals:NSArray!
    
    //MARK: @IBOutlet
    @IBOutlet var stateLabel:UILabel!
    @IBOutlet var shiftLabel:UILabel!
    @IBOutlet var waterLabel:UILabel!
    @IBOutlet var voltLabel:UILabel!
    @IBOutlet var timeLabel:UILabel!
    //@IBOutlet var oilLabel:UILabel!
    @IBOutlet var lapCountLabel:UILabel!
    @IBOutlet var timeStateLabel:UILabel!
    //@IBOutlet var altaTimeLabel:UILabel!
    
    //インスタンスの宣言
    private var shiftNum:Int!
    private var waterNum:Int!
    private var voltNum:Float!
    //    private var oilPresure:Float!
    
    //データベースの設定
    let ref = FIRDatabase.database().reference()
    var snap:FIRDataSnapshot!
    //データを入れる配列
    var contentsArray:[FIRDataSnapshot] = []
    var timeState:[Int]!
    var pylonState:[Int]!
    var flagState: [Int]!
    var lapState: [Int]!
    var timeArray:[Int]!
    
    var count:Float = 0.0
    
    //databaseViewControllerのインスタンスを作成
    let dataV:DataViewController = DataViewController()
    //フラッグとパイロンを表示するImageView
    @IBOutlet var alartImageView:UIImageView!
    @IBOutlet var pylonShot:UIImageView!
    //@IBOutlet var pylonLabel:UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alartImageView.isHidden = true
        //self.reserve()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        //タイムの更新状況を伝えるlabel
        timeStateLabel.layer.masksToBounds = true //枠を丸く
        timeStateLabel.layer.cornerRadius = 20.0  //枠の半径
        //        timeStateLabel.layer.backgroundColor = UIColor.red as! CGColor
        timeStateLabel.backgroundColor =  UIColor.black
        timeStateLabel.text = "タイマー停止中"
        
        //データベースのデータを取得する
        firstCatch()
        
    }
    
    @IBAction func reload(){
        self.centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string:"2A750D7D-BD9A-928F-B744-7D5A70CEF1F9")])
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("state \(central.state)");
        switch (central.state) {
        case .poweredOff:
            print("Bluetoothの電源がOff")
        case .poweredOn:
            print("Bluetoothの電源はOn")
            // BLEデバイスの検出を開始.
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        case .resetting:
            print("レスティング状態")
        case .unauthorized:
            print("非認証状態")
        case .unknown:
            print("不明")
        case .unsupported:
            print("非対応")
        }
    }
    
    
    //検出された際に呼び出される
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //ここでは欲しいシリアルのペリフェラルだけを取得
        if peripheral.name == "BLESerial2"{
            
            var name: NSString? = advertisementData["kCBAdvDataLocalName"] as? NSString
            if (name == nil) {
                name = "no name";
            }
            
            self.peripheral = peripheral
            
            //BLEデバイスが検出された時にペリフェラルの接続を開始する
            self.centralManager.connect(self.peripheral, options:nil)
        }else{
            stateLabel.text = "未発見"
        }
    }
    
    //ペリフェラルの接続が成功するとよばれる
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("接続成功!")
        
        /*ペリフェラルの接続が成功時,
         サービス探索結果を受け取るためにデリゲートをセット*/
        peripheral.delegate = self
        
        //サービス探索開始(nilを渡すことで全てのサービスが探索対象になる)
        peripheral.discoverServices(nil)
        print("サービスの探索を開始しました．")
        
        //スキャンを停止させる
        centralManager.stopScan()
        stateLabel.text = "検出中"
    }
    
    //ペリフェラルの接続が失敗するとよばれる．
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("接続失敗")
        stateLabel.text = "ペリフェラルの接続に失敗"
    }
    
    //サービス発見時に呼ばれるメソッド
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        let servises:NSArray = peripheral.services! as NSArray
        print("\(servises.count)個のサービスを発見")
        
        for obj in servises{
            if let servise = obj as? CBService{
                //キャラクタリスティックの探索を開始する
                peripheral.discoverCharacteristics(nil, for: servise)
            }
        }
    }
    
    //キャラクタリスティックが見つかった時に呼ばれるメソド
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let characteristics:NSArray = service.characteristics! as NSArray
        print("\(characteristics.count)個のキャラクタリスティックを発見! \(characteristics)")
        
        
        for obj in characteristics{
            if let characteristic = obj as? CBCharacteristic{
                
                peripheral.readValue(for: characteristic)
                print("読み出しを開始")
                
                if characteristic.uuid.isEqual(CBUUID(string:"2A750D7D-BD9A-928F-B744-7D5A70CEF1F9")){
                    //Notifyingを開始
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                
            }
        }
    }
    
    
    //キャラクタリスティックが読み出された時に呼ばれるメソッド
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("読み出し成功! service uuid:\(characteristic.service.UUID), characteristic uuid:\(characteristic.UUID), vallue:\(characteristic.value)")
        
        
        if characteristic.uuid.isEqual(CBUUID(string:"2A750D7D-BD9A-928F-B744-7D5A70CEF1F9")){
            
            //var byte:CUnsignedChar = 0
            var byte:CUnsignedChar = 0
            
            //1バイト取り出す
            characteristic.value?.copyBytes(to: &byte, count:1)
            
            print("byte:\(byte)")
            //byteLabel.text = String(byte)
            //            label.text = "\(byte)"
            stateLabel.text = "接続"
            
            //欲しいレンジになっているかを調べる
            if byte >= 0 && byte <= 255{
                //RPM
                if byte >= 200{
                    
                    //シフトポジション
                    shiftNum = (Int(byte) - 200) / 10
                    print("シフト:\(shiftNum!)")
                    if shiftNum > 0 && shiftNum <= 5{
                        shiftLabel.text = String(shiftNum)
                    }else if shiftNum == 6{
                        shiftLabel.text = "N"
                    }else {
                        shiftLabel.text = "X"
                    }
                    
                    //                    //油圧のパターン
                    //                    oilPresure = (Float(Int(byte) - 200))/100
                    //                    print("油圧:\(oilPresure!)")
                    //                    oilLabel.text = "\(oilPresure!)MPa"
                    
                    
                    
                    //水温の場合
                }else if byte >= 0 && byte <= 120{
                    waterNum = Int(byte)
                    print("水温:\(waterNum!)℃")
                    waterLabel.text = "\(waterNum!)"
                    if waterNum >= 100{
                        view.backgroundColor = UIColor.red
                    }
                    
                    
                }else if byte >= 120 && byte <= 150{
                    voltNum = Float(byte) / 10
                    print("volt:\(voltNum!)")
                    voltLabel.text = String(voltNum!)
                    
                }
            }
            
        }
    }
    
    
    //Notifyingが開始された時に呼ばれる
    //状況を伝えるメソッド
    //    func peripheral(peripheral:CBPeripheral,didUpdateNotificationStateForCharacteristic characteristic:CBCharacteristic,error:Error?){
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil{
            print("Notify状態更新失敗...error:\(String(describing: error))")
            stateLabel.text = "更新不可"
            
        }else{
            print("Notify状態更新成功! isNotifying:\(characteristic.isNotifying)")
            
            if characteristic.uuid.isEqual(CBUUID(string:"2A750D7D-BD9A-928F-B744-7D5A70CEF1F9")){
                
                stateLabel.text = "更新中"
                //var byte:CUnsignedChar = 0
                var byte:CUnsignedChar = 0
                
                //1バイト取り出す
                characteristic.value?.copyBytes(to: &byte, count:1)
                
                print("byte:\(byte)")
                //stateLabel.text = String(byte)
                //            label.text = "\(byte)"
                stateLabel.text = "接続"
                
                if byte >= 200{
                    let rpm:Int = (Int(byte) - 200) / 10
                    print("rpm:\(rpm)")
                    //rpmAnime(rpm)
                    
                    let shift:Int = Int(byte) - 200 - rpm
                    print("シフト:\(shift)")
                    shiftLabel.text = String(shift)
                    if shift == 0{
                        shiftLabel.text = "N"
                    }
                    
                }else if byte >= 0 && byte <= 120{
                    let water:Int = Int(byte)
                    print("水温:\(water)")
                    waterLabel.text = String(water)
                    
                    
                }else if byte >= 120 && byte <= 150{
                    let volt:Float = Float(byte) / 10
                    print("電圧:\(volt)")
                    voltLabel.text = String(volt)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    //    //新たにデータを読み込むメソッド
    //    func getNewData(){
    //        ref.child((FIRAuth.auth()?.currentUser?.displayName)!).child("runinfo").observe(.childAdded, with: {(snapshot) in
    //            self.contentsArray.append(snapshot)
    //            //ローカルのデータベースを更新
    //            self.ref.child((FIRAuth.auth()?.currentUser?.displayName)!).child("runinfo").keepSynced(true)
    //            self.format()
    //        })
    //    }
    
    func firstCatch(){
        //今回は，childでrunInfoにアクセスし，ユーザーIDにアクセスする．
        ref.child((FIRAuth.auth()?.currentUser?.displayName)!).child("runinfo").observe(.value, with:{(snapShots) in
            if snapShots.children.allObjects is [FIRDataSnapshot]{
                print("snapShots.children...\(snapShots.childrenCount)")
                print("snapShot...\(snapShots)")
                
                self.snap = snapShots
            }
            self.reload(self.snap)
        })
    }
    
    
    //フラッグや，タイム，パイロンカウントを受信する
    func reserve(){
        //FIRDataEventTypeをValueにすることにより，何かしらの変化があったときに実行
        
        //
        ref.child((FIRAuth.auth()?.currentUser?.displayName)!).child("runinfo").observe(.value, with: {(snapShots) in
            if snapShots.children.allObjects is [FIRDataSnapshot]{
                print("snapShots.children...\(snapShots.childrenCount)")
                print("snapShot...\(snapShots)")
                
                self.snap = snapShots
            }
            self.reload(self.snap)
        }
        )
    }

    
    //読み込んだデータをそれぞれ分ける
    func reload(_ snap:FIRDataSnapshot){
        if snap.exists(){
            print(snap)
            //FIRDataSnapshotsが存在する確認
            contentsArray.removeAll()
            //一つになっているFIRDataSnapshotを分割して入れる
            for item in snap.children{
                contentsArray.append(item as! FIRDataSnapshot)
            }
            
            //ローカルのデータベースを更新
            ref.child((FIRAuth.auth()?.currentUser?.displayName)!).child("runinfo").keepSynced(true)
            //print("ローカルへの更新完了")
            self.format()
        }
    }
    
    
    //出力できるようにする
    func format(){
        
        var formattingArray:[Dictionary<String, Int>] = []
        //アイテムに最終項を代入//
        for i in 0...contentsArray.count-1{
            //配列の該当のデータをitemという定数に代入
            let item = contentsArray[i]
            //itemの中身を辞書型に変換
            let content = item.value as! Dictionary<String, Int>
            //取り出したものを配列に入れる
            formattingArray.append(content)
        }
        //stateという添え字で保存したデータのみを配列として新たに登録
        timeState = formattingArray.map{$0["state"]!}
        print("state\(timeState)")
        
        //pylonという添え字で保存したデータのみを配列として新たに作る
        pylonState = formattingArray.map{$0["pylon"]!}
        print("pylonState\(pylonState)")
        self.pylonTouch()
        //flagという添え字で保持したデータを読み込む
        flagState = formattingArray.map{$0["flag"]!}
        print("flagState:\(flagState)")
        self.flagView()
        //timeという添え字で保存したデータを配列として生成
        timeArray = formattingArray.map{$0["time"]!}
        
        lapState = formattingArray.map{$0["lap"]!}
        lapCountLabel.text = "\(lapState.last!)L"
        self.timeCheck()
        print("受信完了")
    }
    
    //MARK:それぞれの値に対しての処理
    //フォーマットした値に応じたタイマーの処理
    func timeCheck(){
        if timeState.last! >= 1{
            timeStateLabel.text = "測定中"
            timeStateLabel.backgroundColor = UIColor.orange
            let temptime:Float = Float(timeArray.last!) / 100
            timeLabel.text = String(temptime)
            print(temptime)
        }else{
            timeStateLabel.text = "測定外"
            timeStateLabel.backgroundColor = UIColor.black
            timeLabel.text = "0"
        }
        
    }
    
    
    //パイロンタッチを認識した時の処理
    func pylonTouch(){
        //数を表示
        //pylonLabel.text = String(pylonState.last!)
        if pylonState.last! >= 1{
            pylonShot.isHidden = false
            pylonShot.image = UIImage(named:"corn.png")
            
        }else{
            pylonShot.isHidden = true
        }
        
    }
    
    //フラッグが出ている時の処理
    func flagView(){
        //イメージを宣言
        var flagImage = dataV.flagImage
        if flagState.last! == 99 || flagState.last! == 6{
            alartImageView.isHidden = true
        }else{
            alartImageView.image = flagImage[flagState.last!]
            alartImageView.isHidden = false
        }
    }
    
    func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
}


