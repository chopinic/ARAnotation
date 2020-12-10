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
    public var coffeeId: Int;
    public var ui: UIImageView;

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init() {
        self.coffeeName = "";
        self.abstract = "";
        self.coffeeId = -1;
        self.ui = UIImageView()
    }
    init(ui: UIImageView){
        self.coffeeName = "";
        self.abstract = "";
        self.coffeeId = -1;
        self.ui = ui
    }
    
//    init(name: String, info: String, id:Int , image: UIImage, framePos: CGPoint){
//        self.coffeeName = name;
//        self.abstract = info;
//        self.coffeeId = id;
//        updatePosition(position: framePos)
//    }
    
    
//    public func setFrame(frame:CGRect){
//
//    }
    
    public func updatePosition(position: CGPoint){
//        let centerPoint = getCenterPoint(position)
        DispatchQueue.main.async{
            if(self.ui.isHidden==false){self.ui.frame.origin = CGPoint(x: position.x, y: position.y)}
        }
    }
    
//    func getCenterPoint(_ point: CGPoint) -> CGPoint {
//        let xCoord = CGFloat(point.x) - (frame.width) / 2
//        let yCoord = CGFloat(point.y) - (frame.height) / 2
//        return CGPoint(x: xCoord, y: yCoord)
//    }

}
