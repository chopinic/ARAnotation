//
//  BookInfo.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/16.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import UIKit

class UIBookAbstract {
    
    public var id: Int;
    public var isHidden: Bool;
    public var ui: UITextView;

    init(){
        self.id = -1;
        isHidden = true
        ui = UITextView(frame: CGRect(), textContainer: nil)
        DispatchQueue.main.async{
            self.ui.isHidden = true
            self.ui.isEditable = false
            self.ui.layer.cornerRadius = 15.0
            self.ui.layer.borderWidth = 2.0
            self.ui.layer.borderColor = UIColor.gray.cgColor
            self.ui.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            self.ui.frame = CGRect(x: 10, y: 10, width: CGFloat(300), height: CGFloat(250))
        }
    }
//    init(name: String, info: String, id:Int , frame: CGRect){
//        init()
//
//    }
    
    
    func setText(_ str: String){
        DispatchQueue.main.async{
            self.ui.text = str
        }
    }
    
    func getIsHidden()->Bool{
        return isHidden
    }
    
    func setIsHidden(_ hid:Bool){
        isHidden = hid
        DispatchQueue.main.async{
            self.ui.isHidden = hid
        }
    }
 
    public func updatePosition(position: CGPoint){
        if(isHidden==false){
            DispatchQueue.main.async{
                self.ui.frame.origin = CGPoint(x: position.x, y: position.y)
            }
        }
    }
    
//    func getCenterPoint(_ point: CGPoint) -> CGPoint {
//        let xCoord = CGFloat(point.x) - (frame.width) / 2
//        let yCoord = CGFloat(point.y) - (frame.height) / 2
//        return CGPoint(x: xCoord, y: yCoord)
//    }

}
