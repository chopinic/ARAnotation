//
//  BookInfo.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/16.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import UIKit

class UIBookAbstract: UITextView {
    
    private var bookname: String ;
    private var abstract: String ;
    private var bookId: Int;

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(){
        self.bookname = "";
        self.abstract = "";
        self.bookId = -1;
        super.init(frame: CGRect(), textContainer: nil)
        self.text = self.abstract;
    }
    init(name: String, info: String, id:Int , frame: CGRect){
        self.bookname = name;
        self.abstract = info;
        self.bookId = id;
        super.init(frame: frame, textContainer: nil)
        self.text = self.abstract;
    }
    
    
//    public func setFrame(frame:CGRect){
//        
//    }
    
    public func undatePosition(position: CGPoint){
//        let centerPoint = getCenterPoint(position)
        if(isHidden==false){frame.origin = CGPoint(x: position.x, y: position.y)}
    }
    
    func getCenterPoint(_ point: CGPoint) -> CGPoint {
        let xCoord = CGFloat(point.x) - (frame.width) / 2
        let yCoord = CGFloat(point.y) - (frame.height) / 2
        return CGPoint(x: xCoord, y: yCoord)
    }

}
