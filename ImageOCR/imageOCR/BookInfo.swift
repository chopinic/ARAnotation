//
//  BookInfo.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/16.
//  Copyright © 2020 Ivan Nesterenko. All rights reserved.
//

import UIKit

class BookInfo: UITextView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    private var bookname: String ;
    private var detail: String ;
    private var bookId: Int;

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(id:Int){
        self.bookname = "";
        self.detail = "";
        self.bookId = id;
        super.init(frame: CGRect(), textContainer: nil)
        self.text = self.detail;
    }
    init(name: String, info: String, id:Int , frame: CGRect){
        self.bookname = name;
        self.detail = info;
        self.bookId = id;
        super.init(frame: frame, textContainer: nil)
        self.text = self.detail;
    }
    
    
    public func setFrame(frame:CGRect){
        
    }
    
    public func undatePosition(position: CGPoint){
//        let centerPoint = getCenterPoint(position)
        frame.origin = CGPoint(x: position.x, y: position.y)    
    }
    
    func getCenterPoint(_ point: CGPoint) -> CGPoint {
        let xCoord = CGFloat(point.x) - (frame.width) / 2
        let yCoord = CGFloat(point.y) - (frame.height) / 2
        return CGPoint(x: xCoord, y: yCoord)
    }

}
