//
//  Alert.swift
//  nit15-app
//
//  Created by 澤田昂明 on 2017/07/12.
//  Copyright © 2017年 takarki. All rights reserved.
//

import UIKit

class AlertManager:UIAlertController{
    
    let alert:UIAlertController = UIAlertController(title: "接続が切れました", message: "" , preferredStyle: .alert)
    
    func alertView(){
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {ACTION in
            print("okが選択された")
            
        }
        ))
        present(alert,animated: true,completion: nil)
    }
    
}


enum ConnectionMessage : String{
    case connect = "接続完了"
    case not = "接続が切れました"
}
