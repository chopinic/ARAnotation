//
//  SCNNodeEx.swift
//  imageOCR
//
//  Created by 杨光 on 2020/11/3.
//

import Foundation
import ARKit



class BookNode: SCNNode{
    var kind: String!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(){
        super.init()
        kind = "book_name"
    }
    
}

