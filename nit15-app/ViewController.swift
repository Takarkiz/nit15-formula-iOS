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
    
    var centralManager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    @IBOutlet var stateLabel:UILabel!
    @IBOutlet var shiftLabel:UILabel!
    @IBOutlet var waterLabel:UILabel!
    @IBOutlet var voltLabel:UILabel!
    @IBOutlet var rpmLabel:UILabel!
    @IBOutlet var timeLabel:UILabel!
    
    //インスタンスの宣言
    var rpmNum:Int!
    var shiftNum:Int!
    var shiftArray:[Int]!
    var waterNum:Int!
    var waterArray:[Int]!
    var voltNum:Float!
    var voltArray:[Float]!
    
    //データベースの設定
    let ref = FIRDatabase.database().reference()
    var snap:FIRDataSnapshot!
    //データを入れる配列
    var contentsArray:[FIRDataSnapshot] = []
    var timeState:[Int] = []
    var pylonState:[Int] = []
    var flagState: [Int] = []
    //タイマーのインスタンスを呼ぶ
    var timer:Timer = Timer()
    var count:Float = 0.0
    
    
    //スワイプのインスタンスを宣言
    var swipe:UISwipeGestureRecognizer?
    
    //適正値調整用の最大レンジに用いる定数
    let maxShift:Int = 20
    let maxTemp:Int = 15
    let maxVolt:Int = 20
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        // ナビバーの表示を切り替える
        //        if let nv = navigationController {
        //            let hidden = !nv.isNavigationBarHidden
        //            nv.setNavigationBarHidden(hidden, animated: true)
        //        }
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
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
    
    func rpmAnime(x:Int){
        
        if x >= 0 && x <= 9{
            
            rpmLabel.text = "rpm:\(x)"
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
                    rpmNum = (Int(byte) - 200) % 10
                    print("rpm:\(rpmNum)")
                    
                    //シフトポジション
                    shiftNum = (Int(byte) - 200 - rpmNum) / 10
                    print("シフト:\(shiftNum)")
                    
                    //シフトの配列に追加
                    shiftArray.append(shiftNum)
                    if shiftArray.count >= maxShift{
                        self.shiftCheck()
                    }
                    
                    
                    self.rpmAnime(x: rpmNum)
                    shiftLabel.text = String(shiftNum)
                    
                    //水温の場合
                }else if byte >= 0 && byte <= 120{
                    waterNum = Int(byte)
                    print("水温:\(waterNum)℃")
                    waterArray.append(waterNum)
                    if waterArray.count >= maxTemp{
                        self.waterTempCheck()
                    }
                    
                    
                }else if byte >= 120 && byte <= 150{
                    voltNum = Float(byte) / 10
                    if voltNum >= 10 && voltNum <= 14{
                        voltArray.append(voltNum)
                        
                        //ボルト配列がある程度以上になったら，チェックする．
                        self.voltCheck()
                    }
                }
            }
            
        }
    }
    
    
    
    
    //シフポジの適正所作
    //シフトに値が入るたびに呼ばれる
    func shiftCheck(){
        var num:Int = 0
        var count:Bool = false
        for i in 0 ... maxShift-1{
            
            num = num + shiftArray[i]
        }
        
        //シフトチェンジなしの場合
        if num % shiftArray.count == 0{
            if shiftArray[maxShift-1] == 6{
                shiftLabel.text = "N"
            }else{
                shiftLabel.text = String(shiftArray[maxShift-1])
            }
        }else{
            
            //シフトチェンジありの場合の処理
            //たった150ms*10=1.5秒の間に２回もシフトチェンジを行うことはない
            for j in 0...maxShift-2{
                if shiftArray[j+1] - shiftArray[j] == 1 || shiftArray[j+1] - shiftArray[j] == -1 && count == false{
                    count = true
                    
                }else if shiftArray[j+1] - shiftArray[j] == 1 || shiftArray[j+1] - shiftArray[j] == -1 && count == true{
                    count = false
                    break
                }
            }
            if count{
                if shiftArray[maxShift-1] == 6{
                    shiftLabel.text = "N"
                }else{
                    shiftLabel.text = String(shiftArray[maxShift-1])
                }
            }
            
        }
        
        //メモリ空間は残したまま配列の要素のみ削除
        shiftArray.removeAll(keepingCapacity: true)
    }
    
    
    //水温の適正所作
    func waterTempCheck(){
        for i in 0...maxTemp-2{
            if waterArray[i+1] - waterArray[i] <= 5 && waterArray[i+1] - waterArray[i] >= -5{
                waterLabel.text = String(waterArray[i+1])
                if waterArray[i+1] > 100{
                    self.view.backgroundColor = UIColor.red
                }else{
                    self.view.backgroundColor = UIColor.black
                }
            }
        }
        
        waterArray.removeAll(keepingCapacity: true)
    }
    
    
    
    //バッテリー電圧の適正所作
    func voltCheck(){
        for i in 0...maxVolt-2{
            if voltArray[i+1] - voltArray[i] <= 0.5 && voltArray[i+1] - voltArray[i] >= -0.5{
                voltLabel.text = String(voltArray[i+1])
            }
        }
        voltArray.removeAll(keepingCapacity: true)
    }
    
    
    
    
    
    
    
    //Notifyingが開始された時に呼ばれる
    //状況を伝えるメソッド
    //    func peripheral(peripheral:CBPeripheral,didUpdateNotificationStateForCharacteristic characteristic:CBCharacteristic,error:Error?){
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil{
            print("Notify状態更新失敗...error:\(error)")
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
                    if shift == 6{
                        shiftLabel.text = "N"
                    }
                    
                }else if byte >= 0 && byte <= 120{
                    let water:Int = Int(byte)
                    print("水温:\(water)")
                    waterLabel.text = String(water)
                    
                    if water > 100{
                        self.view.backgroundColor = UIColor.red
                    }else{
                        self.view.backgroundColor = UIColor.black
                    }
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
    
    //スワイプの設定
    func swipeSetting(){
        //インスタンス
        swipe = UISwipeGestureRecognizer()
        //スワイプの方向を決める
        swipe!.direction = .right
        //スワイプするときの指の本数
        swipe!.numberOfTouchesRequired = 1
        //スワイプしたときのアクション
        swipe!.addTarget(self, action: #selector(ViewController.back))
        //viewにスワイプジェスチャーを配置
        self.view.addGestureRecognizer(swipe!)
    }
    
    //フラッグや，タイム，パイロンカウントを受信する
    func reserve(){
        //FIRDataEventTypeをValueにすることにより，何かしらの変化があったときに実行
        //今回は，childでrunInfoにアクセスし，ユーザーIDにアクセスする．
        ref.child("runInfo").child((FIRAuth.auth()?.currentUser?.displayName)!).observe(.value, with:{(snapShots) in
            if snapShots.children.allObjects is [FIRDataSnapshot]{
                print("snapShots.children...\(snapShots.childrenCount)")
                print("snapShot...\(snapShots)")
                
                self.snap = snapShots
            }
            self.reload(self.snap)
        })
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
            ref.child("runInfo").child((FIRAuth.auth()?.currentUser?.displayName)!).keepSynced(true)
            self.format()
            
            self.format()
        }
    }
    
    //出力できるようにする
    func format(){
        
        var formattingArray:[Dictionary<String, Int>]!
        //アイテムに最終項を代入
        for i in 0...contentsArray.count{
            //配列の該当のデータをitemという定数に代入
            let item = contentsArray[i]
            //itemの中身を辞書型に変換
            let content = item.value as! Dictionary<String, Int>
            //取り出したものを配列に入れる
            formattingArray.append(content)
        }
        
        //timeという添え字で保存したデータのみを配列として新たに登録
        timeState = formattingArray.map{$0["time"]!}
        //pylonという添え字で保存したデータのみを配列として新たに作る
        pylonState = formattingArray.map{$0["pylon"]!}
        print(pylonState)
        //flagという添え字で保持したデータを読み込む
        flagState = formattingArray.map{$0["flag"]!}
        print(flagState)
        
    }
    
    //フォーマットした値に応じた処理
    
    
    //タイマーのオン・オフ
    func timerFunc(){
        if !timer.isValid{
            //タイマーが作動してなかったら動かす
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.up), userInfo: nil, repeats: true)
        }
    }
    
    //タイマーの数を繰り上げ，表示する関数
    func up(){
        count = count + 0.01
        timeLabel.text = String(format: "%.2fs", count)
    }
    
    //日付を得て，フォーマットする
    func getDate(number:TimeInterval) -> String{
        let date = Date(timeIntervalSince1970: number)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH/mm/ss"
        return formatter.string(from: date)
    }
    
    func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //ナビゲーションバーの非表示
    
}
