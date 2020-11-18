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
    init(name: String, info: String, id:Int , frame: CGRect){
        bookname = name;
        detail = info;
        bookId = id;
        super.init(frame: frame, textContainer: nil)
        text = detail;
    }
    

}
