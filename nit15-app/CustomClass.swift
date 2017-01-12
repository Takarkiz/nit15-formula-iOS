//
//  CustomClass.swift
//  nit15-app
//
//  Created by 澤田昂明 on 2017/01/12.
//  Copyright © 2017年 takarki. All rights reserved.
//

import Foundation
import UIKit

class CustomButton: NSObject {
    
    //ボタンに関するカスタムクラス
    @IBDesignable class CustomButton:UIButton{
        
        //角丸の半径
        @IBInspectable var cornerRadius:CGFloat = 0.0
        
        //枠
        @IBInspectable var borderColor:UIColor = UIColor.clear
        @IBInspectable var borderWidth:CGFloat = 0.0
        
        override func draw(_ rect: CGRect) {
            //角丸
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = (cornerRadius > 0)
            
            //枠線
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = borderWidth
            
            super.draw(rect)
        }
    }
}
