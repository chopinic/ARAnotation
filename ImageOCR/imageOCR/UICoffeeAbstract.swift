//
//  BookInfo.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/16.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import UIKit

class UICoffeeAbstract {
    
    public var coffeeName: String ;
    public var abstract: String ;
    public var id: Int;
    public var imageW: CGFloat = 150;
    public var textW: CGFloat = 300;
    public var ui: UIImageView;
    public var textUI : UITextView;
    private var isHidden = true;
//    public var isHidden

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init() {
        self.coffeeName = "";
        self.abstract = "";
        self.id = -1;
        self.ui = UIImageView()
        self.textUI = UITextView()
        DispatchQueue.main.async{
            self.textUI.layer.cornerRadius = 15.0
            self.textUI.layer.borderWidth = 2.0
            self.textUI.layer.borderColor = UIColor.gray.cgColor
            self.textUI.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
            self.textUI.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            self.textUI.frame = CGRect(x: 10, y: 10, width: CGFloat(self.textW), height: CGFloat(self.imageW))
            self.textUI.isHidden = self.isHidden
            self.ui.frame = CGRect(x: 10, y: 10, width: CGFloat(self.imageW), height: CGFloat(self.imageW))
            self.ui.isHidden = self.isHidden

        }
    }
    
    func getIsHidden()->Bool{
        return isHidden
    }
    
    func setIsHidden(_ hid:Bool){
        isHidden = hid
        DispatchQueue.main.async{
            self.ui.isHidden = hid
            self.textUI.isHidden = hid
        }
    }
    
    func setImage(_ img: UIImage){
        DispatchQueue.main.async{
            self.ui.image = img
        }
    }
    func setText(_ text: String){
        DispatchQueue.main.async{
            self.textUI.text = text
        }
    }

    public func updatePosition(position: CGPoint){
//        let centerPoint = getCenterPoint(position)
        if(isHidden==false){
            DispatchQueue.main.async{
                self.ui.frame.origin = CGPoint(x: position.x, y: position.y)
                self.textUI.frame.origin = CGPoint(x: position.x+self.imageW, y: position.y)
            }
        }
    }
}
